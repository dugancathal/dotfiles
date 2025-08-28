-- ===dotfiles===
vim.bo.expandtab=true
vim.bo.tabstop=2
vim.bo.shiftwidth=2
vim.bo.softtabstop=2
vim.opt.smartindent = true

vim.opt.nu = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>mkd", ":!mkdir -p %:h<CR>")
