local M = {}

-- Minimal initial state
local state = {
	layout_detector = nil,
	notification_handler = nil,
}

-- Cached environment check (only computed once)
local function get_environment()
	if state.env then
		return state.env
	end

	-- Quick checks in order of likelihood
	if vim.env.DISPLAY then
		state.env = "x11"
	elseif vim.env.WAYLAND_DISPLAY then
		state.env = "wayland"
	elseif vim.fn.has("win32") == 1 then
		state.env = "windows"
	elseif vim.fn.has("mac") == 1 then
		state.env = "macos"
	else
		state.env = "unknown"
	end

	return state.env
end

-- Efficient layout detectors (only load what's needed for current environment)
local layout_detectors = {
	x11 = function()
		-- Most efficient X11 check using xset
		return vim.fn.system("xset -q | grep LED | awk '{print $10}' | cut -c5"):gsub("%s+", "") == "0"
	end,

	wayland = function()
		-- Minimal Wayland check
		if vim.fn.executable("swaymsg") == 1 then
			return vim.fn
				.system([[swaymsg -t get_inputs | grep "xkb_active_layout_name" | head -1 | cut -d'"' -f4]])
				:match("^[Ee]nglish")
		end
		return true -- Fallback if can't detect
	end,

	windows = function()
		-- Efficient Windows check using simpler PowerShell command
		local layout = vim.fn.system(
			[[powershell -c "Get-WinUserLanguageList | Select-Object -First 1 | Select-Object -ExpandProperty LanguageTag"]]
		)
		return layout:match("^en")
	end,

	macos = function()
		-- Simplified macOS check
		local layout = vim.fn.system(
			[[defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID]]
		)
		return layout:match("US") or layout:match("ABC")
	end,
}

-- Efficient layout checking
local function is_layout_english()
	if not state.layout_detector then
		local env = get_environment()
		state.layout_detector = layout_detectors[env]
	end

	if state.layout_detector then
		return state.layout_detector()
	end
	return true -- Fallback to allowing if we can't detect
end

-- Setup notification handler (lazy loaded)
local function get_notification_handler()
	if state.notification_handler then
		return state.notification_handler
	end

	-- Try to use noice.nvim if available
	local has_noice, _ = pcall(require, "noice")
	if has_noice then
		state.notification_handler = function(msg)
			vim.notify(msg, vim.log.levels.WARN, {
				title = "Keyboard Layout",
				timeout = 1000,
			})
		end
	else
		-- Fallback to simple notify
		state.notification_handler = function(msg)
			vim.notify(msg, vim.log.levels.WARN)
		end
	end

	return state.notification_handler
end

-- Main keypress handler
local function handle_keypress()
	if not is_layout_english() then
		get_notification_handler()("Please switch to English layout")
		return true
	end
	return false
end

-- Minimal setup with efficient autocommands
function M.setup(opts)
	opts = opts or {}

	-- Single autogroup for all autocommands
	local group = vim.api.nvim_create_augroup("KeyboardGuard", { clear = true })

	-- Only create autocommands that are needed
	if opts.protect_cmdline ~= false then
		vim.api.nvim_create_autocmd("CmdlineEnter", {
			group = group,
			callback = handle_keypress,
		})
	end

	-- Protect normal mode operations efficiently
	if opts.protect_normal ~= false then
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			callback = function()
				vim.keymap.set("n", ".", function()
					return handle_keypress() and "" or "."
				end, { expr = true, buffer = true })
			end,
		})
	end
end

return m
