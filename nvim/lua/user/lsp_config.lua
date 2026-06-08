-- lsp_config (using vim.lsp.config / vim.lsp.enable for Neovim 0.11+)

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Apply capabilities to all servers
vim.lsp.config('*', {
    capabilities = capabilities,
})

-- Server-specific configurations
vim.lsp.config('pyright', {
    settings = {
        python = {
            analysis = {
                useLibraryCodeForTypes = true
            },
            path = "/usr/bin/python3"
        }
    },
})

vim.lsp.config('ts_ls', {
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
    },
})

vim.lsp.config('gopls', {
    cmd = {'gopls', '-remote=auto', '-rpc.trace', '-v'},
    flags = {
        debounce_text_changes = 1000,
    },
    settings = {
        gopls = {
            staticcheck = true,
            gofumpt = true,
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
})

vim.lsp.config('ulsp', {
    cmd = { "socat", "-", "tcp:localhost:27883,ignoreeof" },
    filetypes = { "go", "java" },
    root_markers = { ".git" },
    flags = {
        debounce_text_changes = 1000,
    },
    single_file_support = false,
})

local tw_highlight = require('tailwind-highlight')
vim.lsp.config('tailwindcss', {
    on_attach = function(client, bufnr)
        tw_highlight.setup(client, bufnr, {
            single_column = false,
            mode = 'background',
            debounce = 200,
        })
    end,
})

-- Enable all servers
vim.lsp.enable({
    'clangd',
    'pyright',
    'ts_ls',
    'bashls',
    'jdtls',
    'prosemd_lsp',
    'html',
    'tailwindcss',
    'cssls',
    'cssmodules_ls',
    'emmet_ls',
    'eslint',
    'arduino_language_server',
    'gopls',
    'ulsp',
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
})

local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Information = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

require("lsp_lines").setup{}

-- Setup fidget.nvim for LSP status notifications
require("fidget").setup{}

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = false,
    float = {
        border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
    },
})
