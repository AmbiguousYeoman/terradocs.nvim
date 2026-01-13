-- Minimal init.lua for running tests
-- This sets up the Neovim environment for plenary tests

local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"

-- Add plugins to runtimepath (assume they're already cloned in CI)
vim.opt.runtimepath:prepend(".")
vim.opt.runtimepath:append(plenary_dir)
vim.opt.runtimepath:append(treesitter_dir)

-- Set up basic options
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax enable]])

-- Load plenary busted (required for PlenaryBustedDirectory/PlenaryBustedFile)
require("plenary.busted")
