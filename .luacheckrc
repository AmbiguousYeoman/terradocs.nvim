-- Luacheck configuration for terradocs.nvim

-- Global vim namespace
globals = {
	"vim",
}

-- Read-only globals
read_globals = {
	"describe",
	"it",
	"before_each",
	"after_each",
	"pending",
	"assert",
}

-- Ignore unused arguments (common in callbacks)
unused_args = false

-- Max line length
max_line_length = false

-- Ignore specific warnings
ignore = {
	"212", -- Unused argument
	"631", -- Line too long
}

-- Files to exclude
exclude_files = {
	".luacheckrc",
}
