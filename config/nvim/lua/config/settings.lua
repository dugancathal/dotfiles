vim.bo.expandtab=true
vim.bo.tabstop=2
vim.bo.shiftwidth=2
vim.bo.softtabstop=2

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>mkd", ":!mkdir -p %:h<CR>")
