-- Minimal init.lua for running tests
-- This sets up the Neovim environment for plenary tests

local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"

-- Add plugins to runtimepath FIRST
vim.opt.runtimepath:prepend(".")
vim.opt.runtimepath:prepend(plenary_dir)
vim.opt.runtimepath:prepend(treesitter_dir)

-- Override notify to print to stdout for CI visibility
vim.notify = print

-- Set up basic options
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

-- Set leader key for keymap tests
vim.g.mapleader = " "

-- Enable filetype detection and syntax
vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax enable]])

-- Load plenary busted which creates the commands
require("plenary.busted")
