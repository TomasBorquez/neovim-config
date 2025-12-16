function GetDay()
  local currentDate = os.date("*t")
  local startOfYear = os.time({ year = currentDate.year, month = 1, day = 1 })
  local currentTime = os.time(currentDate)
  local daysDiff = math.floor((currentTime - startOfYear) / (60 * 60 * 24))
  return daysDiff + 1
end

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

function GetPath(path)
  local script_path = debug.getinfo(1).source:match("@?(.*/)") or ""
  return script_path .. path
end

function GetBufferDir()
  local path = Cwd()
  if path then
    return path
  end

  local current_buffer_dir = vim.fn.expand('%:p:h')
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(current_buffer_dir) .. ' rev-parse --show-toplevel')
      [1]

  if vim.v.shell_error == 0 and git_root then
    return git_root
  end

  return current_buffer_dir
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

local function get_dad_joke()
  local file = io.open(GetPath("../data/dad-jokes.txt"), "r")
  if not file then
    return print("Could not read file")
  end
  local current_line = 0
  local current_day = GetDay()
  for line in file:lines() do
    current_line = current_line + 1
    if current_line == current_day then
      file:close()
      return line
    end
  end
  file:close()
end

local function split_on_angle_brackets(str)
  local result = {}
  for segment in string.gmatch(str, "[^<>]+") do
    table.insert(result, segment)
  end
  return result
end

function GetPadding(text, width)
  local padding = width - #text
  if padding < 0 then padding = 0 end
  return math.floor(padding / 2)
end

function CenterText(text, width)
  local pad_left_count = GetPadding(text, width)
  local left_pad = string.rep(" ", pad_left_count)
  return left_pad .. text
end

local function wrap_text(text, width)
  local line = ""
  local lines = {}
  local words = {}

  for word in text:gmatch("%S+") do
    table.insert(words, word)
  end

  for _, word in ipairs(words) do
    if #line + #word + 1 <= width then
      if #line > 0 then
        line = line .. " " .. word
      else
        line = word
      end
    else
      table.insert(lines, line)
      line = word
    end
  end

  if #line > 0 then
    table.insert(lines, line)
  end

  return lines
end

function CreateCowsay()
  local joke = get_dad_joke()
  local joke_parts = split_on_angle_brackets(joke)
  local width = 60
  local setup = joke_parts[1]
  local punchline = joke_parts[2]
  assert(#joke_parts == 2, "CreateCowsay: Failed, Setup/Punchline are not available, length should be 2")

  local left_pad_spaces = "    "
  local setup_lines = wrap_text(setup, width - #left_pad_spaces)
  local punchline_lines = wrap_text(punchline, width - #left_pad_spaces)
  local cowsay = {}

  -- Square start
  table.insert(cowsay, left_pad_spaces .. string.rep("_", width - 3))

  for i, line in ipairs(setup_lines) do
    local padded_line = line .. string.rep(" ", width - #left_pad_spaces - #line)
    if i == 1 then
      table.insert(cowsay, "   / " .. padded_line .. "\\")
    else
      table.insert(cowsay, "  |  " .. padded_line .. " |")
    end
  end

  for i, line in ipairs(punchline_lines) do
    local padded_line = line .. string.rep(" ", width - #left_pad_spaces - #line)
    if i ~= #punchline_lines then
      table.insert(cowsay, "  |  " .. padded_line .. " |")
    else
      table.insert(cowsay, "   \\ " .. padded_line .. "/")
    end
  end

  -- Square end
  table.insert(cowsay, left_pad_spaces .. string.rep("-", width - 3))

  -- Cow ASCII art centered
  local cow_art = {
    "\\   ^__^",
    " \\  (oo)\\_______",
    "    (__)\\       )\\/\\",
    "        ||----w |",
    "        ||     ||"
  }

  local pad_left_count = GetPadding(cow_art[5], width)
  for _, line in ipairs(cow_art) do
    local left_pad = string.rep(" ", pad_left_count)
    table.insert(cowsay, left_pad .. line)
  end

  table.insert(cowsay, "")

  local prog_config = CenterText("[p] Programming   [c] Config", width + #left_pad_spaces)
  table.insert(cowsay, prog_config)
  table.insert(cowsay, "")

  -- Add special date to the formatted date line
  local special_date = GetSpecialDate()
  local date_string = os.date("%I:%M %p | %d-%m-%Y")
  if special_date ~= "" then
    date_string = date_string .. " | " .. special_date
  end
  local formattedDate = CenterText(date_string, width + #left_pad_spaces)
  table.insert(cowsay, 1, formattedDate)
  return cowsay
end

function GetSpecialDate()
  local current_date = os.date("*t")
  local month = current_date.month
  local day = current_date.day

  -- New Year (January 1)
  if month == 1 and day == 1 then
    return "New Year's Day 🎊"
  end

  -- Summer in Argentina (December through February)
  if (month == 12) or (month == 1) or (month == 2) then
    return "Summer in Argentina ☀️"
  end

  -- Valentine's Day (February 14)
  if month == 2 and day == 14 then
    return "Valentine's Day 💕"
  end

  -- Carnival (February/March)
  if (month == 2 and day >= 20) or (month == 3 and day <= 5) then
    return "Carnival 🎭"
  end

  -- National Memory Day (March 24)
  if month == 3 and day == 24 then
    return "National Memory Day 🇦🇷"
  end

  -- Fall in Argentina (March through May)
  if month >= 3 and month <= 5 then
    return "Fall in Argentina 🍂"
  end

  -- Labor Day (May 1)
  if month == 5 and day == 1 then
    return "Labor Day 🇦🇷"
  end

  -- May Revolution Day (May 25)
  if month == 5 and day == 25 then
    return "May Revolution Day 🇦🇷"
  end

  -- Winter in Argentina (June through August)
  if month >= 6 and month <= 8 then
    return "Winter in Argentina ❄️"
  end

  -- Flag Day (June 20)
  if month == 6 and day == 20 then
    return "Flag Day 🇦🇷"
  end

  -- Independence Day (July 9)
  if month == 7 and day == 9 then
    return "Independence Day 🇦🇷"
  end

  -- San Martín Day (August 17)
  if month == 8 and day == 17 then
    return "San Martín Day 🇦🇷"
  end

  -- Student's Day (September 21)
  if month == 9 and day == 21 then
    return "Student's Day 📚"
  end

  -- Spring in Argentina (September 21 through November)
  if (month == 9 and day >= 21) or (month == 10 or month == 11) then
    return "Spring in Argentina 🌸"
  end

  -- Respect for Cultural Diversity Day (October 12)
  if month == 10 and day == 12 then
    return "Cultural Diversity Day 🌍"
  end

  -- National Sovereignty Day (November 20)
  if month == 11 and day == 20 then
    return "National Sovereignty Day 🇦🇷"
  end

  -- Christmas Eve and Day (December 24-25)
  if month == 12 and (day == 24 or day == 25) then
    return "Christmas 🎄"
  end

  return ""
end

-- INFO: Called on VimEnter
function SetDayColor()
  local current_date = os.date("*t")
  local month = current_date.month
  local day = current_date.day
  local color = "#9FA8DA" -- Default
  local argentina_color = "#61afef"

  -- New Year (January 1)
  if month == 1 and day == 1 then
    color = "#BF360C"
    -- Summer in Argentina (December through February)
  elseif (month == 12) or (month == 1) or (month == 2) then
    color = "#e5c07b"
    -- Valentine's Day (February 14)
  elseif month == 2 and day == 14 then
    color = "#e06c75"
    -- Carnival (February/March)
  elseif (month == 2 and day >= 20) or (month == 3 and day <= 5) then
    color = "#c678dd"
    -- National Memory Day (March 24)
  elseif month == 3 and day == 24 then
    color = argentina_color
    -- Fall in Argentina (March through May)
  elseif month >= 3 and month <= 5 then
    color = "#d19a66"
    -- Labor Day (May 1)
  elseif month == 5 and day == 1 then
    color = argentina_color
    -- May Revolution Day (May 25)
  elseif month == 5 and day == 25 then
    color = argentina_color
    -- Winter in Argentina (June through August)
  elseif month >= 6 and month <= 8 then
    color = "#7a8496"
    -- Flag Day (June 20)
  elseif month == 6 and day == 20 then
    color = argentina_color
    -- Independence Day (July 9)
  elseif month == 7 and day == 9 then
    color = argentina_color
    -- San Martín Day (August 17)
  elseif month == 8 and day == 17 then
    color = argentina_color
    -- Spring in Argentina (September 21 through November) - CORREGIDO
  elseif (month == 9 and day >= 21) or (month == 10 or month == 11) then
    color = "#98c379"
    -- Student's Day (September 21)
  elseif month == 9 and day == 21 then
    color = "#00897B"
    -- Respect for Cultural Diversity Day (October 12)
  elseif month == 10 and day == 12 then
    color = "#e5c07b"
    -- National Sovereignty Day (November 20)
  elseif month == 11 and day == 20 then
    color = argentina_color
    -- Christmas Eve and Day (December 24-25)
  elseif month == 12 and (day == 24 or day == 25) then
    color = "#98c379"
  end

  vim.cmd(string.format([[highlight StartifyHeader guifg=%s]], color))
end

function IsWindows()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

function IsLinux()
  return vim.fn.has('win32') ~= 1 and vim.fn.has('win64') ~= 1
end

CreateCowsay()
