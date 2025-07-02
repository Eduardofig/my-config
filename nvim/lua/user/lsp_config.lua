-- lsp_config

function bemol()
    local bemol_dir = vim.fs.find({ '.bemol' }, { upward = true, type = 'directory'})[1]
    local ws_folders_lsp = {}
    if bemol_dir then
        local file = io.open(bemol_dir .. '/ws_root_folders', 'r')
        if file then

            for line in file:lines() do
                table.insert(ws_folders_lsp, line)
            end
            file:close()
        end
    end

    for _, line in ipairs(ws_folders_lsp) do
        vim.lsp.buf.add_workspace_folder(line)
    end

end

local on_attach_bemol = function(_, bufnr)
    bemol()
end

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
        on_attach = on_attach_bemol,
    },
    --[[ sumneko_lua = {}, ]]
    --rust_analyzer = {},
    bashls = {},
    jdtls = {
        on_attach = on_attach_bemol,
    },
    prosemd_lsp = {},
    html = {},
    tailwindcss = {},
    cssls = {},
    cssmodules_ls = {},
    emmet_ls = {},
    eslint = {},
    arduino_language_server = {},
    --[[ gopls = {}, ]]
    omnisharp = {},

    --[[ sqlls = {}, ]]
}

local installer_opts = {
    automatic_installation = true,
    ensure_installed = server_list
}

local lsp_installer = require "nvim-lsp-installer"

lsp_installer.setup(installer_opts)

local lspcfg = require "lspconfig"
require('rust-tools').setup{}

for server, opts in pairs(server_list) do
    lspcfg[server].setup(opts)
end


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
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

require("gopher").setup{}
require("lsp_lines").setup{}

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
    virtual_text = false,
})

vim.diagnostic.config({ virtual_lines = false })
