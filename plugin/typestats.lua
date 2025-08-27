local M = {}

M.chars_typed = 0
M.start_time = vim.loop.hrtime()
M.wpm = 0
M.last_key_time = vim.loop.hrtime()

local break_keys = {
  ["<BS>"]   = true,
  ["<Del>"]  = true,
  ["<Left>"] = true,
  ["<Right>"]= true,
  ["<Up>"]   = true,
  ["<Down>"] = true,
  ["<C-h>"]  = true,
  ["<C-w>"]  = true,
  ["<C-u>"]  = true,
  ["<Esc>"]  = true,
}

vim.on_key(function(key)
  if vim.fn.mode() ~= "i" then return end
  local now = vim.loop.hrtime()
  M.last_key_time = now

  local term = vim.api.nvim_replace_termcodes(key, true, true, true)

  if break_keys[term] then
    return
  end

  if #term == 1 and term:match("[%g%s]") then
    M.chars_typed = M.chars_typed + 1
  end

  local elapsed = (now - M.start_time) / 1e9 / 60
  if elapsed > 0 then
    M.wpm = math.floor((M.chars_typed / 5) / elapsed)
  end
end)

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    M.start_time = vim.loop.hrtime()
    M.last_key_time = M.start_time
    M.chars_typed = 0
    M.wpm = 0
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    M.chars_typed = 0
    M.wpm = 0
  end,
})

local timer = vim.loop.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
  local now = vim.loop.hrtime()
  local idle = (now - M.last_key_time) / 1e9
  if idle > 5 then
    M.chars_typed = 0
    M.wpm = 0
    M.start_time = now
  end
end))

function M.statusline()
  if vim.fn.mode() ~= "i" then
    return "[WPM:0]"
  end
  return string.format("[WPM:%d]", M.wpm)
end

_G.TypeStats = M
return M

