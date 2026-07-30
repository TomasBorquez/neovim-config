-- [[ Auto Commands ]]
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

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("spell_prose", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "tex", "plaintex" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- [[ User Commands ]]
for name, path in pairs(Paths.commands) do
  local cmd = vim.endswith(path, "/") and (":Oil " .. path) or (":e " .. path)
  vim.api.nvim_create_user_command(name, cmd, {})
end
