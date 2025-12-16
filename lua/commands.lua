-- Auto Commands
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    vim.opt.formatoptions:remove({ 'c', 'o' })
  end
})

-- User Commands
local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
if is_windows then
  vim.api.nvim_create_user_command('AppData', ':Oil ~/AppData/', {})
  vim.api.nvim_create_user_command('Shada', ':Oil ~/AppData/Local/nvim-data/shada/', {})
  vim.api.nvim_create_user_command('Config', ':Oil ~/AppData/Local/nvim/', {})
  vim.api.nvim_create_user_command('Programming', ':Oil ~/Programming/learn/', {})
else
  vim.api.nvim_create_user_command('Shada', ':Oil ~/.local/state/nvim/shada/', {})
  vim.api.nvim_create_user_command('Config', ':Oil ~/.config/nvim/', {})
  vim.api.nvim_create_user_command('Programming', ':Oil ~/programming/learn/', {})
  vim.api.nvim_create_user_command('Ideas', ':Oil ~/programming/ideas/', {})
  vim.api.nvim_create_user_command('Linux', ':Oil ~/programming/learn/linux/', {})
  vim.api.nvim_create_user_command('VM', ':Oil ~/programming/learn/qemu-kernel-vm/', {})
end

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
