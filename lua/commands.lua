-- Auto Commands
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    SetDayColor()
  end
})
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    print("Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms")
  end,
})
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    vim.opt.formatoptions:remove({ 'c', 'o' })
  end
})

-- User Commands
vim.api.nvim_create_user_command('Config', ':Oil ~/AppData/Local/nvim/', {})
vim.api.nvim_create_user_command('Programming', ':Oil ~/Desktop/Programming/', {})
vim.api.nvim_create_user_command('Home', 'Startify', {})
