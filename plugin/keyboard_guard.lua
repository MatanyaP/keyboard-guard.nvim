if vim.fn.has("nvim-0.8.0") == 0 then
	vim.api.nvim_err_writeln("keyboard-guard requires at least Neovim 0.8.0")
	return
end

-- Prevent loading more than once
if vim.g.loaded_keyboard_guard == 1 then
	return
end
vim.g.loaded_keyboard_guard = 1

-- Global variable to enable/disable the plugin
vim.g.keyboard_guard_enabled = true
