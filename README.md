# typestats.nvim

A tiny Neovim plugin that tracks your typing speed (WPM) and streaks in insert mode, and shows them in the built-in statusline.

## Installation

Use your plugin manager of choice. Example with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "saltytine/typestats.nvim",
  name = "typestats",
  config = function()
    vim.o.statusline = "%f %h%m%r %=%{v:lua.TypeStats.statusline()}"
  end,
},
```
