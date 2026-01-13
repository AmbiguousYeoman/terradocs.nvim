-- Minimal init.lua for running tests
-- This sets up the Neovim environment for plenary tests

local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"

-- Override notify to print to stdout for CI visibility
vim.notify = print

-- Add plugins to runtimepath
vim.opt.runtimepath:prepend(".")
vim.opt.runtimepath:append(plenary_dir)
vim.opt.runtimepath:append(treesitter_dir)

-- Set up basic options
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

-- Load plugins
vim.cmd([[runtime plugin/plenary.vim]])

-- Enable filetype detection and syntax
vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax enable]])

-- Ensure plenary busted commands are available
require("plenary.busted")
