vim.bo.expandtab=true
vim.bo.tabstop=2
vim.bo.shiftwidth=2
vim.bo.softtabstop=2

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
--vim.g.mapleader = " "
--vim.g.maplocalleader = "\\"

require("config.lazy")

local opts = {
  checker = { enabled = true },
}

local plugins = {
  { "catppuccin/nvim", name = "catpuccin", priority = 1000 },
  { "ibhagwan/fzf-lua", name = "fzf-lua", priority = 1000 },
  {
    "neovim/nvim-lspconfig",
  },
}

require("lazy").setup(plugins, opts)

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

local lsp = require("lspconfig")

lsp.ruby_lsp.setup{}
