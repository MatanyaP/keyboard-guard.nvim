-- vim: ft=lua tw=80

cache = true
codes = true
formatter = "plain"

-- Glorious list of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
	"212", -- Unused argument
	"121", -- Setting read-only global variable 'vim'
	"122", -- Setting read-only field of global variable 'vim'
}

-- Global objects defined by Neovim
read_globals = {
	"vim",
}

-- Don't report unused self arguments of methods
self = false

-- Global objects defined by the project
globals = {
	"keyboard_guard",
}

-- Path to search for external definitions
exclude_files = {
	".luacheckrc",
}

-- Max line length
max_line_length = 120

-- Max cyclomatic complexity
max_cyclomatic_complexity = 15
