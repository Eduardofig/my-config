-- lsp_config

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local server_list = {
    clangd = {},
    --[[ jedi_language_server = {}, ]]
    --[[ pylsp = {}, ]]
    pyright = {
        python = {
            analysis = {
                useLibraryCodeForTypes = true
            }, 
            path = "/usr/bin/python3"
        }
    },
    ts_ls = {
        filetypes = { 
            "javascript", 
            "javascriptreact", 
            "javascript.jsx", 
            "typescript", 
            "typescriptreact", 
            "typescript.tsx" 
        }
    },
    --[[ sumneko_lua = {}, ]]
    --rust_analyzer = {},
    bashls = {},
    jdtls = {},
    prosemd_lsp = {},
    html = {},
    tailwindcss = {},
    cssls = {},
    cssmodules_ls = {},
    emmet_ls = {},
    eslint = {},
    arduino_language_server = {},
    gopls = {
        cmd = {'gopls', '-remote=auto', '-rpc.trace', '-v'},
        --[[ cmd = {'gopls'}, ]]
        --[[ on_attach = on_attach, ]]
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 1000, -- Optimized from 1000ms
        },
        --[[ root_dir = function(fname) ]]
        --[[     local util = require('lspconfig.util') ]]
        --[[]]
        --[[     -- First, try to find the git root ]]
        --[[     local git_root = util.find_git_ancestor(fname) ]]
        --[[     if not git_root then ]]
        --[[         return nil ]]
        --[[     end ]]
        --[[]]
        --[[     -- Check if we're in go-code-sparse (sparse checkout) ]]
        --[[     if git_root:match("go%-code%-sparse$") then ]]
        --[[         -- For sparse checkout, use src/code.uber.internal as root ]]
        --[[         local sparse_root = git_root .. "/src/code.uber.internal" ]]
        --[[         if vim.fn.isdirectory(sparse_root) == 1 then ]]
        --[[             return sparse_root ]]
        --[[         end ]]
        --[[     end ]]
        --[[]]
        --[[     -- For regular go-code, look for go.mod in standard locations ]]
        --[[     local go_mod_root = util.root_pattern("go.mod", "go.work")(fname) ]]
        --[[     if go_mod_root then ]]
        --[[         return go_mod_root ]]
        --[[     end ]]
        --[[]]
        --[[     -- Fallback to git root ]]
        --[[     return git_root ]]
        --[[ end, ]]
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
    },
    ulsp = {
        capabilities = capabilities,
    },
    --[[ omnisharp = {}, ]]

    --[[ sqlls = {}, ]]
}

local installer_opts = {
    automatic_installation = true,
    ensure_installed = server_list
}

require("lspconfig.configs").ulsp = {
    default_config = {
        cmd = { "socat", "-", "tcp:localhost:27883,ignoreeof" },
        flags = {
            debounce_text_changes = 1000,
        },
        capabilities = capabilities,
        filetypes = { "go", "java" },
        root_dir = function(fname)
            local result = require("lspconfig.async").run_command({ "git", "rev-parse", "--show-toplevel" })
            if result and result[1] then
                return vim.trim(result[1])
            end
            return require("lspconfig.util").root_pattern(".git")(fname)
        end,
        single_file_support = false,
    },
}

local lsp_installer = require "nvim-lsp-installer"

lsp_installer.setup(installer_opts)

local lspcfg = require "lspconfig"
--[[ require('rust-tools').setup{} ]]

for server, opts in pairs(server_list) do
    lspcfg[server].setup(opts)
end


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
})

local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Information = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

local tw_highlight = require('tailwind-highlight')

lspcfg.tailwindcss.setup({
    on_attach = function(client, bufnr)
        -- rest of you config
        tw_highlight.setup(client, bufnr, {
            single_column = false,
            mode = 'background',
            debounce = 200,
        })
    end
})

--[[ require("gopher").setup{} ]]
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
