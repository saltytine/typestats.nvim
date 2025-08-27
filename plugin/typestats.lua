local M = {}

M.chars_typed = 0
M.start_time = vim.loop.hrtime()
M.streak = 0
M.max_streak = 0
M.wpm = 0

local break_keys = {
  ["<BS>"] = true,
  ["<Del>"] = true,
  ["<Left>"] = true,
  ["<Right>"] = true,
  ["<Up>"] = true,
  ["<Down>"] = true,
  ["<C-h>"] = true,
  ["<C-w>"] = true,
  ["<C-u>"] = true,
  ["<Esc>"] = true,
}

local ns = vim.api.nvim_create_namespace("typestats")

vim.on_key(function(key)
  if vim.fn.mode() ~= "i" then return end

  local term = vim.api.nvim_replace_termcodes(key, true, true, true)

  if break_keys[term] then
    if M.streak > M.max_streak then
      M.max_streak = M.streak
    end
    M.streak = 0
    return
  end

  if key:match("%C") then
    M.chars_typed = M.chars_typed + 1
    M.streak = M.streak + 1
  end

  local elapsed = (vim.loop.hrtime() - M.start_time) / 1e9 / 60
  if elapsed > 0 then
    M.wpm = math.floor((M.chars_typed / 5) / elapsed)
  end
end, ns)

function M.statusline()
  return string.format("[WPM:%d] [Streak:%d/%d]", M.wpm, M.streak, M.max_streak)
end

_G.TypeStats = M
return M

