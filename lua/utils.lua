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
  local lines = {}
  local line = ""
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
  -- local frog_art = {
  --   "       _     _",
  --   "      (')-=-(')",
  --   "    __(   \"   )__",
  --   "   / _/'-----'\\_ \\",
  --   "___\\\\ \\\\     // //___",
  --   ">____)/_\\---/_\\(____<"
  -- }

  local pad_left_count = GetPadding(cow_art[5], width)
  for _, line in ipairs(cow_art) do
    local left_pad = string.rep(" ", pad_left_count)
    table.insert(cowsay, left_pad .. line)
  end

  table.insert(cowsay, "")

  local prog_config = CenterText("[p] Programming   [c] Config", width + #left_pad_spaces)
  table.insert(cowsay, prog_config)
  table.insert(cowsay, "")

  local formattedDate = CenterText(os.date("%I:%M %p | %d-%m-%Y"), width + #left_pad_spaces)
  table.insert(cowsay, 1, formattedDate)
  return cowsay
end

function SetDayColor()
  local current_date = os.date("*t")
  local month = current_date.month
  local day = current_date.day

  local color = "#9FA8DA" -- Default
  local argentina_color = "#61afef"

  -- New Year (January 1) - Universal
  if month == 1 and day == 1 then
    color = "#BF360C" -- Orange

    -- Summer in Argentina (December through February)
  elseif (month == 12) or (month == 1) or (month == 2) then
    color = "#e5c07b" -- Sunny yellow

    -- Valentine's Day (February 14) - Universal
  elseif month == 2 and day == 14 then
    color = "#e06c75" -- Pink/Red

    -- Carnival (February/March)
  elseif (month == 2 and day >= 20) or (month == 3 and day <= 5) then
    color = "#c678dd" -- Purple

    -- National Memory Day (March 24) - Argentina
  elseif month == 3 and day == 24 then
    color = argentina_color

    -- Fall in Argentina (March through May)
  elseif month >= 3 and month <= 5 then
    color = "#d19a66" -- Autumn orange/brown

    -- May Revolution Day (May 25) - Argentina
  elseif month == 5 and day == 25 then
    color = argentina_color

    -- Winter in Argentina (June through August)
  elseif month >= 6 and month <= 8 then
    color = "#5c6370" -- Gray blue for winter

    -- Independence Day (July 9) - Argentina
  elseif month == 7 and day == 9 then
    color = argentina_color

    -- Spring in Argentina (September through November)
  elseif month >= 9 and month <= 11 then
    color = "#98c379" -- Green for spring

    -- Student's Day (September 21) - Argentina
  elseif month == 9 and day == 21 then
    color = "#00897B" -- Bright green

    -- Respect for Cultural Diversity Day (October 12) - Argentina
  elseif month == 10 and day == 12 then
    color = "#e5c07b" -- Yellow

    -- Christmas Eve and Day (December 24-25) - Universal
  elseif month == 12 and (day == 24 or day == 25) then
    color = "#98c379" -- Green
  end

  vim.cmd(string.format([[highlight StartifyHeader guifg=%s]], color))
end
