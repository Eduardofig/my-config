// Opencode TUI plugin: always-visible spend in the sidebar.
//
// Loaded as a TUI-kind plugin via ~/.config/opencode/tui.json — the default
// export must be `{ id, tui }` (server() and tui() cannot coexist in one
// plugin per opencode's readV1Plugin validation).
//
// Data source: shells out to `aifx statusline show --agent opencode`. That
// command owns everything network-related — auth, the endpoint, the HTTP
// timeout, the TTL'd on-disk cache, and the cross-process single-flight lock.
// `show` itself never blocks on the network: it reads the cache and, when
// stale, fires a detached `aifx statusline refresh` (the same one the Claude
// statusline uses). So this plugin holds no spend/refresh timing of its own —
// REFRESH_MS below is purely how often the widget re-reads the cache to
// repaint; the actual fetch cadence is statusline's 1-minute TTL + lock.
//
// Rendering: opencode's TUI is @opentui/solid. External plugins can't use JSX,
// so we dynamic-import `solid-js` + `@opentui/solid` (Bun resolves both from
// opencode's bundled deps) and reconstruct what `<text>{signal()}</text>`
// compiles to: createElement + insert(el, signalFn) for reactive tracking.
// Slot registration needs `id` or the host's isHostSlotPlugin check no-ops;
// order 101 places us just below the built-in Context section (order 100).
//
// Fail-open: every step is wrapped in try/catch; on any failure the plugin
// returns {} and opencode is never blocked.

import { execFile } from "child_process"
import { promisify } from "util"

const execFileAsync = promisify(execFile)

// AGENT is forwarded to `aifx statusline show --agent`. opencode has its own
// spend-status endpoint, so it queries its own cap rather than claude-code's.
const AGENT = "opencode"
const AIFX_BIN = process.env.AIFX_BIN || "aifx"
// REFRESH_MS is the widget repaint cadence (re-read the cache), not a network
// interval — statusline owns the real fetch timing via its cache TTL + lock.
const REFRESH_MS = 30 * 1000
const DISABLED = process.env.CI === "true"

// fetchSpend invokes the aifx spend command and parses its JSON envelope.
// Returns { ok: false } on any failure (binary missing, non-zero exit,
// unparseable output, unavailable). No subprocess timeout here: `aifx
// statusline show` is local-only and bounds itself (spendShowTimeout), so the
// plugin trusts the binary to return promptly.
async function fetchSpend() {
  let stdout
  try {
    ;({ stdout } = await execFileAsync(
      AIFX_BIN,
      ["statusline", "show", "--agent", AGENT],
      { encoding: "utf-8" },
    ))
  } catch {
    return { ok: false }
  }
  try {
    const body = JSON.parse(stdout)
    if (!body || body.available !== true) return { ok: false }
    return { ok: true, data: body }
  } catch {
    return { ok: false }
  }
}

function fmtUsd(n) {
  if (typeof n !== "number" || !isFinite(n)) return "$?"
  return `$${Math.round(n)}`
}

// fmtAmount renders the spend line. The shape depends on what the binary
// returns, acting as a natural feature switch across aifx binary versions:
//
//   pool-aware binary (pool_spend_usd present):
//     "opencode $85 | pool $720/$2,000"
//       tool_spend_usd = this agent's spend; pool_spend_usd/cap_usd = pool.
//
//   pre-pool binary (no pool_spend_usd):
//     "$108 of $1,500 cap"
//       spend_usd/cap_usd = this agent's own spend and cap.
//
// spend_usd always means this agent's own spend, so the fallback line is
// correct on both old and new binaries. Only the pool breakdown is gated.
function fmtAmount(s) {
  if (!s) return "(loading…)"
  if (typeof s.pool_spend_usd === "number" && isFinite(s.pool_spend_usd)) {
    const tool = fmtUsd(s.tool_spend_usd)
    const pool = `${fmtUsd(s.pool_spend_usd)}/${fmtUsd(s.cap_usd)}`
    return `${AGENT} ${tool} | pool ${pool}`
  }
  return `${fmtUsd(s.spend_usd)} of ${fmtUsd(s.cap_usd)} cap`
}

const plugin = {
  id: "aifx-spending-tui",
  tui: async (api) => {
    if (DISABLED) return {}

    let solid = null
    let opentuiSolid = null
    try { solid = await import("solid-js") } catch {}
    try { opentuiSolid = await import("@opentui/solid") } catch {}
    if (!solid || !opentuiSolid) return {}

    const { createSignal } = solid
    const { createElement, insert, effect, setProp } = opentuiSolid
    if (!createElement || !insert) return {}

    const [spend, setSpend] = createSignal(null)
    const [status, setStatus] = createSignal("loading") // "loading" | "ok" | "unavailable"

    async function refresh() {
      const r = await fetchSpend()
      if (r.ok) {
        setSpend(r.data)
        setStatus("ok")
        return
      }
      // Sticky last-good: only flip to "unavailable" if we never had a value.
      // Transient failures shouldn't blank out a previously-good number.
      if (spend() == null) setStatus("unavailable")
    }

    // Register the slot before arming the poller: if registration throws, the
    // widget shows nothing, so don't leave a timer shelling out to aifx.
    try {
      api.slots.register({
        id: "aifx-spending-tui",
        order: 101,
        slots: {
          sidebar_content() {
            const t = () => api.theme.current

            const header = createElement("text")
            insert(header, () => "Harness Pool Spending")
            if (effect && setProp) effect(() => setProp(header, "fg", t() && t().text))
            if (effect && setProp) effect(() => setProp(header, "attributes", 1)) // bold

            const amount = createElement("text")
            insert(amount, () => {
              const st = status()
              if (st === "loading") return "(loading…)"
              if (st === "unavailable") return "Unavailable"
              return fmtAmount(spend())
            })
            if (effect && setProp) effect(() => setProp(amount, "fg", t() && t().textMuted))

            const box = createElement("box", { marginTop: 1 })
            insert(box, header)
            insert(box, amount)
            return box
          },
        },
      })
    } catch {
      return {}
    }

    refresh().catch(() => { if (spend() == null) setStatus("unavailable") })
    const timer = setInterval(() => {
      refresh().catch(() => { if (spend() == null) setStatus("unavailable") })
    }, REFRESH_MS)

    return {
      dispose: async () => { clearInterval(timer) },
    }
  },
}

export default plugin
