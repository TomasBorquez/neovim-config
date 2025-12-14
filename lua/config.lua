vim.o.guifont = "Comic Mono:h14:#e-subpixelantialias"
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.g.mapleader = " "
vim.g.c_syntax_for_h = 1 -- detect .h files
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
vim.opt.wrap = false
vim.opt.updatetime = 300
vim.opt.fileformat = "unix"
vim.opt.fileformats = "unix,dos"
vim.opt.list = true
vim.opt.listchars:append({ tab = "  ", trail = "·" })
vim.bo.fileformat = "unix"

if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
  vim.opt.swapfile = false
end

vim.g.clipboard = {
  name = 'win32yank',
  copy = {
    ['+'] = 'win32yank.exe -i --crlf',
    ['*'] = 'win32yank.exe -i --crlf',
  },
  paste = {
    ['+'] = 'win32yank.exe -o --lf',
    ['*'] = 'win32yank.exe -o --lf',
  },
  cache_enabled = 0,
}

vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
})

vim.loader.enable()

-- Unused default plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_rplugin = 1
