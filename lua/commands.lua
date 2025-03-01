-- Auto Commands
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    SetDayColor()
  end
})
-- User Commands
vim.api.nvim_create_user_command('Programming', ':Oil ~/Desktop/Programming/', {})
vim.api.nvim_create_user_command('Home', 'Startify', {})
