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

-- vim.keymap.set("n", "<leader>u", "i#ID:<Esc>:read !uuidgen<Enter>kJx:s/-//g<Enter>", { desc = "insert an upcase UUID with no -" })
local function insert_uuid()
  local uuid = vim.fn.system('uuidgen'):gsub('%s+', ''):gsub('-', '')
  vim.api.nvim_put({"ID:" .. uuid}, 'c', true, true)
end
vim.keymap.set('n', '<leader>u', insert_uuid, { desc = 'Insert UUID from shell' })
