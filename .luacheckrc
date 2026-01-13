-- Luacheck configuration for terradocs.nvim

std = "luajit"

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

-- Max line length
max_line_length = false

-- Ignore specific warnings
ignore = {
	"211", -- Unused local variable
	"212", -- Unused argument
	"213", -- Unused loop variable
	"311", -- Value assigned to local variable is unused
	"631", -- Line too long
}

-- Files to exclude
exclude_files = {
	".luacheckrc",
}
