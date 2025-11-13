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
vim.api.nvim_create_user_command('AppData', ':Oil ~/AppData/', {})
vim.api.nvim_create_user_command('Config', ':Oil ~/AppData/Local/nvim/', {})
vim.api.nvim_create_user_command('Shada', ':Oil ~/AppData/Local/nvim-data/shada/', {})
vim.api.nvim_create_user_command('Programming', ':Oil ~/Programming/learn/', {})
vim.api.nvim_create_user_command('Home', 'Startify', {})

-- Screenshot/Presentation Mode Toggle
local screenshot_mode = false

vim.cmd("highlight GHint guifg=#8D73F5 ctermfg=98 gui=bold cterm=bold")
vim.cmd("highlight RHint guifg=#F57373 ctermfg=98 gui=bold cterm=bold")

vim.api.nvim_create_user_command('ScreenshotMode', function()
  screenshot_mode = not screenshot_mode

  if screenshot_mode then
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.cursorcolumn = false
    vim.opt.signcolumn = "no"
    vim.opt.laststatus = 0
    vim.opt.showcmd = false
    vim.opt.ruler = false
    vim.opt.showmode = false
    vim.opt.cmdheight = 0
    vim.opt.colorcolumn = ""
    vim.opt.foldcolumn = "0"

    if vim.g.neovide_scale_factor then vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.4 end
  else
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.signcolumn = "yes"
    vim.opt.laststatus = 2
    vim.opt.showcmd = true
    vim.opt.ruler = true
    vim.opt.showmode = true
    vim.opt.cmdheight = 1

    if vim.g.neovide_scale_factor then vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.4 end
  end
end, {})

vim.api.nvim_create_user_command('MatchClear', function()
  vim.fn.clearmatches()
end, {})
