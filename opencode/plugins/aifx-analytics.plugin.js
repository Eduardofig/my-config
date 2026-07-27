// Forwards opencode lifecycle events to `aifx analytics emit --agent opencode`.
// Fire-and-forget: analytics never blocks opencode.

import { spawn } from "child_process";
import { appendFileSync, mkdirSync } from "fs";
import { homedir } from "os";
import { dirname, join } from "path";

const AIFX_BIN = process.env.AIFX_BIN || "aifx";
const DISABLED = process.env.AIFX_DISABLE_ANALYTICS === "1";
const DEBUG = process.env.AIFX_ANALYTICS_DEBUG === "1";
const DEBUG_LOG = join(homedir(), ".aifx", "analytics", "opencode_plugin.log");

let binaryMissing = false;

const debugLog = (line) => {
  if (!DEBUG) return;
  try {
    mkdirSync(dirname(DEBUG_LOG), { recursive: true });
    appendFileSync(DEBUG_LOG, `${new Date().toISOString()} | ${line}\n`);
  } catch {}
};

const emit = (payload) => {
  if (DISABLED || binaryMissing) return;
  try {
    const json = JSON.stringify(payload);
    debugLog(`emit ${payload.hook_event_name}: ${json}`);
    const child = spawn(AIFX_BIN, ["analytics", "emit", "--agent", "opencode"], {
      stdio: ["pipe", "ignore", "ignore"],
      detached: true,
    });
    child.on("error", (err) => {
      if (err && err.code === "ENOENT") binaryMissing = true;
      debugLog(`spawn error: ${err?.message ?? err}`);
    });
    child.stdin.on("error", (err) => debugLog(`stdin error: ${err?.message ?? err}`));
    child.stdin.end(json);
    child.unref();
  } catch (err) {
    debugLog(`emit threw: ${err?.message ?? err}`);
  }
};

// Maps opencode tool IDs (registry.ts) and provider-surfaced aliases (e.g.
// "bash" for shell when claude is the LLM) to claude-style names.
const TOOL_NAMES = {
  edit: "Edit",
  write: "Write",
  read: "Read",
  glob: "Glob",
  grep: "Grep",
  task: "Task",
  todo: "TodoWrite",
  todowrite: "TodoWrite",
  todoread: "TodoRead",
  skill: "Skill",
  question: "Question",
  plan: "Plan",
  lsp: "LSP",
  invalid: "Invalid",
  shell: "Bash",
  bash: "Bash",
  fetch: "WebFetch",
  webfetch: "WebFetch",
  search: "WebSearch",
  websearch: "WebSearch",
  patch: "ApplyPatch",
  apply_patch: "ApplyPatch",
};
const normalizeTool = (t) => TOOL_NAMES[String(t || "").toLowerCase()] || t || "";

// Must stay in sync with cases handled in DefaultHookEventMapper (hook.go).
// Args for tools outside this set are dropped — Go would discard them and
// raw_input.log would otherwise capture todos/plans/sub-agent prompts.
const EXTRACTED_TOOLS = new Set(["Edit", "Write", "Bash", "Skill"]);

// Translates opencode camelCase to canonical snake_case so hook.go stays
// opencode-unaware.
const ARG_KEY_MAP = {
  filePath: "file_path",
  oldString: "old_string",
  newString: "new_string",
};
const argsFor = (toolName, args) => {
  if (!EXTRACTED_TOOLS.has(toolName) || !args || typeof args !== "object") return {};
  const out = {};
  for (const [k, v] of Object.entries(args)) {
    out[ARG_KEY_MAP[k] || k] = v;
  }
  return out;
};

const promptText = (parts) => {
  if (!Array.isArray(parts)) return "";
  const text = parts.find((p) => p && p.type === "text");
  return text?.text ?? "";
};

export const aifxAnalytics = async ({ directory, worktree }) => {
  const cwd = worktree || directory || process.cwd();
  const base = (sessionID) => ({ session_id: sessionID || "", cwd });

  return {
    // Generic event stream for bus events with no dedicated hook key. The
    // typed "permission.ask" hook in the type definition is never triggered
    // in opencode's source — must use the bus event instead.
    event: async ({ event }) => {
      if (!event || typeof event !== "object") return;
      const type = event.type;
      const props = event.properties || {};
      const sid = props.sessionID || props.info?.id || "";
      switch (type) {
        case "session.created":
          emit({ ...base(sid), hook_event_name: "SessionStart", source: "startup" });
          break;
        case "session.deleted":
          emit({ ...base(sid), hook_event_name: "SessionEnd" });
          break;
        // session.idle is deprecated in favor of session.status; handle both.
        case "session.idle":
          emit({ ...base(sid), hook_event_name: "Stop" });
          break;
        case "session.status":
          if (props.status?.type === "idle") {
            emit({ ...base(sid), hook_event_name: "Stop" });
          }
          break;
        case "session.error":
          emit({
            ...base(sid),
            hook_event_name: "PostToolUseFailure",
            error: String(props.error?.message ?? props.error ?? "session error"),
          });
          break;
        case "permission.asked":
          emit({
            ...base(sid),
            hook_event_name: "PermissionRequest",
            tool_name: normalizeTool(props.tool || props.title || ""),
          });
          break;
      }
    },

    "chat.message": async (input, output) => {
      emit({
        ...base(input.sessionID),
        hook_event_name: "UserPromptSubmit",
        prompt: promptText(output?.parts),
      });
    },

    "tool.execute.before": async (input, output) => {
      const tool = normalizeTool(input.tool);
      emit({
        ...base(input.sessionID),
        hook_event_name: "PreToolUse",
        tool_name: tool,
        tool_input: argsFor(tool, output?.args),
        tool_use_id: input.callID || "",
      });
    },

    // After-hook places args on `input`, not `output`.
    "tool.execute.after": async (input, _output) => {
      const tool = normalizeTool(input.tool);
      emit({
        ...base(input.sessionID),
        hook_event_name: "PostToolUse",
        tool_name: tool,
        tool_input: argsFor(tool, input.args),
        tool_use_id: input.callID || "",
      });
    },
  };
};
