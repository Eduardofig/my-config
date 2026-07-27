-- rust_tools (using rustaceanvim, successor to rust-tools.nvim)
-- Inlay hints are handled natively by Neovim 0.10+ (vim.lsp.inlay_hint)

-- Share nvim-cmp completion capabilities with rust-analyzer
local ok_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

-- Resolve a rust-analyzer command that works even when the binary isn't
-- directly on $PATH (e.g. when installed via `rustup component add rust-analyzer`
-- on a homebrew rustup setup, which doesn't create a proxy for it).
local function rust_analyzer_cmd()
    if vim.fn.executable('rust-analyzer') == 1 then
        return { 'rust-analyzer' }
    end
    if vim.fn.executable('rustup') == 1 then
        return { 'rustup', 'run', 'stable', 'rust-analyzer' }
    end
    return { 'rust-analyzer' } -- last-ditch fallback; will error loudly
end

vim.g.rustaceanvim = {
  tools = {
    hover_actions = {
      border = {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
      },
      auto_focus = false,
    },
    crate_graph = {
      backend = "x11",
      output = nil,
      full = true,
      enabled_graphviz_backends = {
        "bmp",
        "cgimage",
        "canon",
        "dot",
        "gv",
        "xdot",
        "xdot1.2",
        "xdot1.4",
        "eps",
        "exr",
        "fig",
        "gd",
        "gd2",
        "gif",
        "gtk",
        "ico",
        "cmap",
        "ismap",
        "imap",
        "cmapx",
        "imap_np",
        "cmapx_np",
        "jpg",
        "jpeg",
        "jpe",
        "jp2",
        "json",
        "json0",
        "dot_json",
        "xdot_json",
        "pdf",
        "pic",
        "pct",
        "pict",
        "plain",
        "plain-ext",
        "png",
        "pov",
        "ps",
        "ps2",
        "psd",
        "sgi",
        "svg",
        "svgz",
        "tga",
        "tiff",
        "tif",
        "tk",
        "vml",
        "vmlz",
        "wbmp",
        "webp",
        "xlib",
        "x11",
      },
    },
  },

  server = {
    cmd = rust_analyzer_cmd(),
    standalone = true,
    capabilities = capabilities,
    default_settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        -- Use clippy for `cargo check` on save
        checkOnSave = { command = 'clippy' },
        procMacro = {
          enable = true,
          ignored = {
            ['async-trait'] = { 'async_trait' },
            ['napi-derive'] = { 'napi' },
            ['async-recursion'] = { 'async_recursion' },
          },
        },
        inlayHints = {
          bindingModeHints = { enable = false },
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
          closureReturnTypeHints = { enable = 'never' },
          lifetimeElisionHints = { enable = 'never', useParameterNames = false },
          maxLength = 25,
          parameterHints = { enable = true },
          reborrowHints = { enable = 'never' },
          renderColons = true,
          typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
        },
      },
    },
  },

  dap = {
    adapter = {
      type = "executable",
      command = "lldb-vscode",
      name = "rt_lldb",
    },
  },
}
