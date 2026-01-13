-- Minimal init.lua for running tests
-- This sets up the Neovim environment for plenary tests

local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"

-- Clone plenary if not present
if vim.fn.isdirectory(plenary_dir) == 0 then
	vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

-- Clone nvim-treesitter if not present
if vim.fn.isdirectory(treesitter_dir) == 0 then
	vim.fn.system({ "git", "clone", "https://github.com/nvim-treesitter/nvim-treesitter", treesitter_dir })
end

-- Add plugins to runtimepath
vim.opt.runtimepath:prepend(".")
vim.opt.runtimepath:append(plenary_dir)
vim.opt.runtimepath:append(treesitter_dir)

-- Set up basic options
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax enable]])
