-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable mouse
-- vim.opt.mouse = ""

-- Use terminal background color
vim.cmd([[
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight LineNr ctermbg=NONE guibg=NONE
  highlight SignColumn ctermbg=NONE guibg=NONE
]])

-- Your other custom options
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- Add any other settings you want to customize

vim.opt.clipboard = "unnamedplus" -- Connect to system clipboard
vim.opt.mousemodel = "popup_setpos"

-- Enable mouse only in normal and visual modes, not in terminal mode
vim.opt.mouse = "nv"

-- This helps with proper selection behavior
vim.opt.mousemodel = "popup_setpos"
