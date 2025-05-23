vim.o.guifont = "Comic Mono:h13:#e-subpixelantialias"
vim.g.mapleader = " "
vim.g.c_syntax_for_h = 1 -- Detect .h files
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
vim.opt.fileformat = "unix"
vim.opt.fileformats = "unix,dos"
vim.bo.fileformat = "unix"

vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
})

vim.loader.enable()
