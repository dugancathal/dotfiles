require("fzf-lua").setup({ "default" })

vim.api.nvim_set_keymap("n", "<C-p>", [[<Cmd>lua require"fzf-lua".git_files()<CR>]], {})
