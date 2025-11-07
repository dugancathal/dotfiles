-- ===dotfiles===
require("config.settings")
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

require("config.fzf")
require("config.lsp")
require("plugins.gitcoauthor")
