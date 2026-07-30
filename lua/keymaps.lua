vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>")
vim.keymap.set("n", "<leader>n", "<cmd>nohl<CR>")

vim.keymap.set("n", "<leader>t", "<CMD>Oil<CR>")
vim.keymap.set("n", "<leader>bo", "<cmd>silent! %bd|e#|bd#<cr>")

vim.keymap.set("n", ">", ">>")
vim.keymap.set("n", "<", "<<")
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("x", "<", "<gv")

vim.keymap.set("v", "<C-c>", function()
  vim.schedule(function() vim.cmd("normal! \"+y") end)
end)

vim.keymap.set({ "n", "v" }, "<leader>v", function()
  vim.schedule(function() vim.cmd("normal! \"+p") end)
end)

vim.keymap.set("i", "<C-S-v>", "<C-r><C-r>+")
vim.keymap.set("c", "<C-S-v>", "<C-r><C-r>+")

vim.keymap.set("n", "<Leader>cm", function()
  vim.fn.setreg("+", vim.fn.execute("messages"))
end)

vim.keymap.set("n", "gh", function()
  vim.lsp.buf.hover()
end)

vim.keymap.set("v", "<leader>p", "\"_dP")

-- [[ Spelling ]]
vim.keymap.set("n", "<leader>ss", function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  print("spell " .. (vim.opt_local.spell:get() and "on" or "off"))
end)

local function typo_under_cursor()
  if not vim.wo.spell then
    return false
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local typo = vim.fn.spellbadword()[1]
  local found = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, pos)

  return typo ~= "" and found[1] == pos[1] and found[2] <= pos[2] and pos[2] < found[2] + #typo
end

vim.keymap.set("n", "<C-.>", function()
  if typo_under_cursor() then
    local themes = require("telescope.themes")
    require("telescope.builtin").spell_suggest(themes.get_cursor())
    return
  end

  if next(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/codeAction" })) then
    vim.lsp.buf.code_action()
  end
end)

-- Same as the diagnostic jump, on a buffer without diagnostics left it walks the typos instead
vim.keymap.set("n", "<leader>m", function()
  if vim.wo.spell then
    vim.cmd("silent! normal! ]s")
  end

  if vim.diagnostic.jump({ count = 1 }) then
    return
  end
end)

-- Fix the typo you just wrote without losing your place
vim.keymap.set("i", "<C-.>", "<C-g>u<Esc>[s1z=`]a<C-g>u")

-- Window navigation
vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")

if vim.g.neovide == true then
  pcall(function() vim.keymap.del("n", "<C-^>") end)

  vim.keymap.set("n", "<C-^>", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
  end)

  vim.keymap.set("n", "<C-->", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
  end)
end

local function map_nop(key, mode)
  vim.keymap.set(mode, key, "<Nop>", { noremap = true })
end

-- [[ Unbinds ]]
map_nop("<C-h>", "i")
map_nop("<C-u>", "i")
map_nop("<C-o>", "i")
map_nop("<C-x>", "i")
map_nop("<C-v>", "i")
map_nop("<C-k>", "i")
map_nop("<C-t>", "i")
map_nop("<C-d>", "i")
map_nop("<C-a>", "i")
map_nop("<C-y>", "i")
map_nop("<C-e>", "i")
map_nop("<C-s>", "i")

map_nop("<C-1>", "n")
map_nop("<C-2>", "n")
map_nop("<C-3>", "n")
map_nop("<C-4>", "n")
map_nop("<C-5>", "n")
map_nop("<C-6>", "n")
map_nop("<C-7>", "n")
map_nop("<C-8>", "n")
map_nop("<C-9>", "n")
map_nop("<C-0>", "n")

map_nop("<C-f>", "n")
