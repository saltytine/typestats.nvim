local M = {}

M.chars_typed = 0
M.start_time = vim.loop.hrtime()
M.streak = 0
M.max_streak = 0
M.wpm = 0
M.last_key_time = vim.loop.hrtime()

local break_keys = {}

vim.on_key(function(key)
  if vim.fn.mode() ~= "i" then return end
  local now = vim.loop.hrtime()
  M.last_key_time = now

  -- normalize key to termcodes
  local term = vim.api.nvim_replace_termcodes(key, true, true, true)

  -- check breaker keys
  if break_keys[term] then
    if M.streak > M.max_streak then
      M.max_streak = M.streak
    end
    M.streak = 0
    return
  end

  -- printable chars only
  if #term == 1 and term:match("[%g%s]") then
    M.chars_typed = M.chars_typed + 1
    M.streak = M.streak + 1
  end

  -- recalc wpm
  local elapsed = (now - M.start_time) / 1e9 / 60
  if elapsed > 0 then
    M.wpm = math.floor((M.chars_typed / 5) / elapsed)
  end
end)

-- reset on insert enter
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    M.start_time = vim.loop.hrtime()
    M.last_key_time = M.start_time
    M.streak = 0
    M.chars_typed = 0
    M.wpm = 0
  end,
})

-- reset on insert leave
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if M.streak > M.max_streak then
      M.max_streak = M.streak
    end
    M.chars_typed = 0
    M.streak = 0
    M.wpm = 0
  end,
})

-- idle reset timer
local timer = vim.loop.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
  local now = vim.loop.hrtime()
  local idle = (now - M.last_key_time) / 1e9
  if idle > 5 then
    M.chars_typed = 0
    M.streak = 0
    M.wpm = 0
    M.start_time = now
  end
end))

function M.statusline()
  if vim.fn.mode() ~= "i" then
    return "[WPM:0] [Streak:0/" .. M.max_streak .. "]"
  end
  return string.format("[WPM:%d] [Streak:%d/%d]", M.wpm, M.streak, M.max_streak)
end

_G.TypeStats = M
return M
