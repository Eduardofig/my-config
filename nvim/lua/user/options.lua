-- options
local options = {
    tabstop = 2,
    softtabstop = 2,
    shiftwidth = 2,
    expandtab = true,
    smartindent = true,
    exrc = true,
    relativenumber = true,
    hlsearch = false,
    hidden = true,
    errorbells = false,
    nu = true,
    wrap = false,
    ignorecase = true,
    smartcase = true,
    backup = false,
    undodir = '/Users/duduffa/.undodir',
    undofile = true,
    incsearch = true,
    termguicolors = true,
    showmode = false,
    mouse = 'a',
    clipboard = 'unnamedplus',
    pumheight = 10,
    mousescroll = 'ver:5'
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

vim.g.mapleader = " "

vim.cmd[[
    augroup NoAutoComment
        au!
        au FileType * setlocal formatoptions-=cro
    augroup end
]]

vim.cmd[[
    set iskeyword-=_
]]
