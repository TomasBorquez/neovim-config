vim.o.guifont = "Comic Mono:h13:#e-subpixelantialias"
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.guicursor = "a:block"
vim.opt.linespace = 4
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.updatetime = 300

vim.diagnostic.config({
  update_in_insert = true, -- Show diagnostics while in insert mode
  virtual_text = true,     -- Show virtual text
  signs = true,            -- Show signs
  underline = true,        -- Underline the text
  severity_sort = true,    -- Sort by severity
})
