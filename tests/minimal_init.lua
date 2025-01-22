-- Minimal init.lua for tests
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local is_windows = vim.fn.has("win32") == 1

if is_windows then
	package.path = string.format(
		"%s;%s\\lua\\?.lua;%s\\lua\\?\\init.lua",
		package.path,
		plenary_dir:gsub("/", "\\"),
		plenary_dir:gsub("/", "\\")
	)
else
	package.path = string.format("%s;%s/lua/?.lua;%s/lua/?/init.lua", package.path, plenary_dir, plenary_dir)
end

-- Add project directory to package path
local project_root = vim.fn.getcwd()
if is_windows then
	package.path = string.format(
		"%s;%s\\lua\\?.lua;%s\\lua\\?\\init.lua",
		package.path,
		project_root:gsub("/", "\\"),
		project_root:gsub("/", "\\")
	)
else
	package.path = string.format("%s;%s/lua/?.lua;%s/lua/?/init.lua", package.path, project_root, project_root)
end
