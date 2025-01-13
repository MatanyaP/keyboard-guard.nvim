local M = {}

local health = vim.health or require("health")

local function check_environment()
	local env = vim.env

	if env.DISPLAY then
		health.ok("X11 environment detected")
		-- Check for xset
		if vim.fn.executable("xset") == 1 then
			health.ok("xset command found")
		else
			health.warn("xset command not found, X11 layout detection may not work")
		end
	elseif env.WAYLAND_DISPLAY then
		health.ok("Wayland environment detected")
		-- Check for swaymsg
		if vim.fn.executable("swaymsg") == 1 then
			health.ok("swaymsg command found")
		else
			health.info("swaymsg not found, using fallback detection method")
		end
	elseif vim.fn.has("win32") == 1 then
		health.ok("Windows environment detected")
		-- Check PowerShell
		if vim.fn.executable("powershell") == 1 then
			health.ok("PowerShell is available")
		else
			health.error("PowerShell not found, plugin will not work properly")
		end
	elseif vim.fn.has("mac") == 1 then
		health.ok("macOS environment detected")
		-- Check defaults command
		if vim.fn.executable("defaults") == 1 then
			health.ok("defaults command found")
		else
			health.error("defaults command not found, plugin will not work properly")
		end
	else
		health.warn("Unknown environment, layout detection may not work")
	end
end

function M.check()
	health.start("keyboard-guard.nvim")

	-- Check Neovim version
	if vim.fn.has("nvim-0.8.0") == 1 then
		health.ok("Neovim version >= 0.8.0")
	else
		health.error("Neovim version must be >= 0.8.0")
	end

	-- Check environment and dependencies
	check_environment()
end

return M
