import { execFile } from "child_process";
import { promisify } from "util";

const execFileAsync = promisify(execFile);

let gatewayHost;
try {
  gatewayHost = new URL(
    process.env.OPENAI_BASE_URL || "https://genai-api.uberinternal.com/v1"
  ).hostname;
} catch {
  gatewayHost = "genai-api.uberinternal.com";
}

let _cachedToken = null;
let _cacheExpiresAt = 0;
let _inflight = null;

const readToken = () => {
  const now = Date.now();
  if (_cachedToken && now < _cacheExpiresAt) return Promise.resolve(_cachedToken);
  if (_inflight) return _inflight;
  _inflight = execFileAsync("usso", ["-ussh", "genai-api", "-print"], {
    encoding: "utf-8",
    timeout: 10000,
  }).then(({ stdout }) => {
    const lines = stdout.split("\n").map((line) => line.trim()).filter(Boolean);
    const token = lines[lines.length - 1];
    if (!token) throw new Error("No token returned by usso");
    _cachedToken = token;
    try {
      const payload = JSON.parse(Buffer.from(token.split(".")[1], "base64url").toString());
      // exp is in seconds; subtract 30s buffer to avoid using an expiring token
      _cacheExpiresAt = payload.exp ? (payload.exp - 30) * 1000 : Date.now() + 60_000;
    } catch {
      _cacheExpiresAt = Date.now() + 60_000;
    }
    _inflight = null;
    return token;
  }).catch((err) => {
    _inflight = null;
    throw err;
  });
  return _inflight;
};

// Strip unsupported anthropic-beta values before requests reach the gateway.
// @ai-sdk/anthropic injects structured-outputs-2025-11-13 unconditionally on
// streaming requests, after all plugin hooks run, so it must be removed here.
const _originalFetch = globalThis.fetch;
const _unsupportedBetas = new Set(["structured-outputs-2025-11-13"]);
globalThis.fetch = async (input, init = {}) => {
  const url =
    typeof input === "string" ? input
    : input instanceof URL ? input.href
    : input?.url ?? "";

  let parsedHost;
  try { parsedHost = new URL(url).hostname; } catch { parsedHost = ""; }
  if (parsedHost !== gatewayHost) {
    return _originalFetch(input, init);
  }

  const headers = new Headers(
    init?.headers || (input instanceof Request ? input.headers : {})
  );
  const betaHeader = headers.get("anthropic-beta");
  if (betaHeader) {
    const filtered = betaHeader
      .split(",")
      .map((v) => v.trim())
      .filter((v) => !_unsupportedBetas.has(v))
      .join(",");
    if (filtered) {
      headers.set("anthropic-beta", filtered);
    } else {
      headers.delete("anthropic-beta");
    }
  }

  return _originalFetch(input, { ...init, headers });
};

export const uberGenai = async (_ctx) => ({
  "chat.headers": async (_input, output) => {
    let token;
    try {
      token = await readToken();
    } catch (err) {
      throw new Error(
        "Uber GenAI: no valid USSO token. SSH into your devpod to authenticate, then retry.\n" +
          `(usso error: ${err.message})`
      );
    }
    output.headers["Authorization"] = `Bearer ${token}`;
    output.headers["x-api-key"] = token;
  },
});
