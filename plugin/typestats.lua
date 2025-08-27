local M = {}

local last_time = nil
local char_count = 0
local streak = 0
local max_streak = 0
local wpm = 0

local timeout = 5000 -- streak timeout in ms
local timer = vim.loop.new_timer()

local function reset_streak()
  streak = 0
end

local function tick()
  if last_time then
    local now = vim.loop.hrtime() / 1e6 -- ms
    if now - last_time > timeout then
      reset_streak()
      wpm = 0
    end
  end
end

local function on_key(key)
  local now = vim.loop.hrtime() / 1e6 -- ms
  if not last_time then
    last_time = now
    return
  end

  local breakers = {
    "<BS>", "<Del>", "<Left>", "<Right>", "<Up>", "<Down>",
  }
  for _, b in ipairs(breakers) do
    if key == vim.api.nvim_replace_termcodes(b, true, true, true) then
      reset_streak()
      last_time = now
      return
    end
  end

  if key:match("^%C$") then
    streak = streak + 1
    if streak > max_streak then
      max_streak = streak
    end

    char_count = char_count + 1

    local elapsed_min = (now - last_time) / 60000
    if elapsed_min > 0 then
      wpm = math.floor((char_count / 5) / elapsed_min)
    end
  end

  last_time = now
end

function M.statusline()
  return string.format("[WPM:%d] [Streak:%d/%d]", wpm, streak, max_streak)
end

function M.setup()
  vim.on_key(on_key, M)
  timer:start(1000, 1000, vim.schedule_wrap(tick))
end

_G.TypeStats = M

return M

