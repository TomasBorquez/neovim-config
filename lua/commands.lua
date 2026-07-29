-- Auto Commands
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "o" })
  end
})

vim.api.nvim_set_hl(0, "HighlightedYankRegion", {
  bg = "#335533",
  fg = "NONE",
  ctermbg = "green",
  ctermfg = "NONE",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = "HighlightedYankRegion",
      timeout = 300,
      on_macro = false,
      on_visual = true,
    })
  end,
})

-- User Commands
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
if is_windows then
  vim.api.nvim_create_user_command("Shada", ":Oil ~/AppData/Local/nvim-data/shada/", {})
  vim.api.nvim_create_user_command("Config", ":Oil ~/AppData/Local/nvim/", {})
  vim.api.nvim_create_user_command("Programming", ":Oil ~/Programming/learn/", {})
  vim.api.nvim_create_user_command("Learn", ":Oil ~/Programming/learn/", {})
  vim.api.nvim_create_user_command("Ideas", ":Oil ~/programming/ideas/", {})
  vim.api.nvim_create_user_command("Bashrc", ":e ~/.bashrc", {})
  vim.api.nvim_create_user_command("Videos", ":Oil ~/programming/videos/", {})
  vim.api.nvim_create_user_command("AppData", ":Oil ~/AppData/", {})
else
  vim.api.nvim_create_user_command("Shada", ":Oil ~/.local/state/nvim/shada/", {})
  vim.api.nvim_create_user_command("Config", ":Oil ~/.config/nvim/", {})
  vim.api.nvim_create_user_command("Programming", ":Oil ~/programming/learn/", {})
  vim.api.nvim_create_user_command("Learn", ":Oil ~/programming/learn/", {})
  vim.api.nvim_create_user_command("Ideas", ":Oil ~/programming/ideas/", {})
  vim.api.nvim_create_user_command("Bashrc", ":e ~/.bashrc", {})
  vim.api.nvim_create_user_command("Kernel", ":Oil ~/programming/learn/kernel/", {})
  vim.api.nvim_create_user_command("VM", ":Oil ~/programming/learn/qemu-kernel-vm/", {})
end
