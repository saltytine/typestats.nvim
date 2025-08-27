if vim.g.loaded_typestats then
  return
end
vim.g.loaded_typestats = true

local M = {}

local typed = 0
local streak = 0
local max_streak = 0
local start_time = vim.loop.hrtime()

vim.api.nvim_create_autocmd("InsertCharPre", {
  callback = function(ev)
    local char = ev.char
    if char == nil then return end

    if char == "\b" or char == vim.api.nvim_replace_termcodes("<BS>", true, true, true) then
      streak = 0
      return
    end

    if char:match("%C") then
      typed = typed + 1
      streak = streak + 1
      if streak > max_streak then
        max_streak = streak
      end
    end
  end,
})

local function get_wpm()
  local now = vim.loop.hrtime()
  local minutes = (now - start_time) / 1e9 / 60
  if minutes <= 0 then return 0 end
  return math.floor((typed / 5) / minutes)
end

function M.statusline()
  return string.format("[WPM:%d][Streak:%d]", get_wpm(), streak)
end

_G.TypeStats = M
return M

