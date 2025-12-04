vim.keymap.set('n', '<leader>q', '<cmd>qa<CR>')
vim.keymap.set('n', '<leader>n', '<cmd>nohl<CR>')

vim.keymap.set("n", "<leader>t", "<CMD>Oil<CR>", { desc = "Open file explorer" })
vim.keymap.set('n', "<leader>ss", "<CMD>luafile %<CR>", { desc = "Execute current lua" })
vim.keymap.set('n', '<leader>bo', '<cmd>silent! %bd|e#|bd#<cr>', { desc = "Close all buffers except current" })

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

vim.keymap.set('n', '<Leader>cm', function()
  vim.fn.setreg('+', vim.fn.execute('messages'))
end)

vim.keymap.set('n', 'gh', function()
  vim.lsp.buf.hover()
end)

vim.keymap.set('v', '<leader>p', '"_dP')
vim.keymap.set('i', '<C-BS>', '<C-W>', { noremap = true })

-- Window navigation
vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = 'Move to window above' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window splits
vim.keymap.set('n', '<leader>ws', '<cmd>vsplit<CR>', { desc = 'Split window vertically' })

if vim.g.neovide == true then
  pcall(function() vim.keymap.del("n", "<C-^>") end)
  vim.api.nvim_set_keymap("n", "<C-^>",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-->",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>", { silent = true })
end

local function map_nop(key, mode)
  vim.keymap.set(mode, key, '<Nop>', { noremap = true })
end

-- Unbind annoying motions:
map_nop('<C-h>', 'i')
map_nop('<C-u>', 'i')
map_nop('<C-o>', 'i')
map_nop('<C-x>', 'i')
map_nop('<C-v>', 'i')
map_nop('<C-k>', 'i')
map_nop('<C-t>', 'i')
map_nop('<C-d>', 'i')
map_nop('<C-a>', 'i')
map_nop('<C-y>', 'i')
map_nop('<C-e>', 'i')
map_nop('<C-s>', 'i')

map_nop('<C-1>', 'n')
map_nop('<C-2>', 'n')
map_nop('<C-3>', 'n')
map_nop('<C-4>', 'n')
map_nop('<C-5>', 'n')
map_nop('<C-6>', 'n')
map_nop('<C-7>', 'n')
map_nop('<C-8>', 'n')
map_nop('<C-9>', 'n')
map_nop('<C-0>', 'n')
