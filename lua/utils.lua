function NormalizePath(path)
  return path:gsub('\\', '/')
end

function Cwd()
  local oil_dir = require("oil").get_current_dir()
  if oil_dir then
    return NormalizePath(oil_dir)
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)
  local path = vim.fn.expand('%:p:h')

  if buf_name:match("^term://") and path:match("^term://") then
    return nil
  end

  return NormalizePath(path)
end

function GetRootDir()
  local path = Cwd()
  if path == nil then
    path = vim.fn.expand('%:p:h')
  end

  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(path) .. ' rev-parse --show-toplevel')
      [1]
  if vim.v.shell_error == 0 and git_root then
    return git_root
  end

  return path
end

function IsWindows()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

function IsLinux()
  return vim.fn.has('win32') ~= 1 and vim.fn.has('win64') ~= 1
end
