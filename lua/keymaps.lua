vim.keymap.set('n', '<leader>q', '<cmd>qa<CR>')
vim.keymap.set('n', '<leader>n', '<cmd>nohl<CR>')

vim.keymap.set('v', 'j', 'gj')
vim.keymap.set('v', 'k', 'gk')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

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
vim.keymap.set("n", "<leader>so", function()
  vim.fn.delete("output.txt")

  vim.cmd("redir! > output.txt")

  vim.cmd("luafile %")

  vim.cmd("redir END")
  print("Output saved to output.txt")
end, { desc = "Output lua file to text file" })

vim.keymap.set('n', '<leader>bo', '<cmd>silent! %bd|e#|bd#<cr>', { desc = "Close all buffers except current" })

vim.keymap.set('n', '<F5>', '<CMD>LspRestart<CR>', { desc = 'Restart LSP server' })
