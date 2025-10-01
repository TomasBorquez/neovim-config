vim.keymap.set('n', '<leader>q', '<cmd>qa<CR>')
vim.keymap.set('n', '<leader>n', '<cmd>nohl<CR>')

vim.keymap.set('n', '>', '>>')
vim.keymap.set('x', '>', '>gv')
vim.keymap.set('n', '<', '<<')
vim.keymap.set('x', '<', '<gv')

vim.keymap.set('v', '<C-c>', function()
  vim.schedule(function()
    vim.cmd('normal! "+y')
  end)
end)
vim.keymap.set({ 'n', 'v' }, '<leader>v', function()
  vim.schedule(function()
    vim.cmd('normal! "+p')
  end)
end)
vim.keymap.set('v', '<leader>p', '"_dP')

vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>')

vim.keymap.set('i', '<C-BS>', '<C-W>', { noremap = true })

vim.keymap.set("n", "<leader>t", "<CMD>Oil<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>h", "<CMD>Home<CR>", { desc = "Go home" })
vim.keymap.set("n", "<leader>ss", "<CMD>luafile %<CR>", { desc = "Execute current lua" })

vim.keymap.set('n', '<Leader>sm', function()
  vim.fn.setreg('+', vim.fn.execute('messages'))
end, { desc = 'Copy messages to system clipboard' })

vim.keymap.set('n', '<leader>bo', '<cmd>silent! %bd|e#|bd#<cr>', { desc = "Close all buffers except current" })

vim.keymap.set('n', '<F5>', '<CMD>LspRestart<CR>', { desc = 'Restart LSP server' })

if vim.g.neovide == true then
  pcall(function() vim.keymap.del("n", "<C-^>") end)
  vim.api.nvim_set_keymap("n", "<C-^>",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-->",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>", { silent = true })
end
