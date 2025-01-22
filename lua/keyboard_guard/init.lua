-- lua/keyboard_guard/init.lua
local M = {}

-- State management
local state = {
	enabled = true,
	env = nil,
	detector = nil,
	notify_fn = nil,
}

-- Default configuration
local defaults = {
	notification = {
		enabled = true,
		style = "minimal",
		message = "Please switch to English layout!",
		level = vim.log.levels.WARN,
	},
	modes = {
		n = true,
		i = false,
		c = true,
	},
}

-- Layout detection
local function is_english()
	if not state.enabled then
		return true
	end
	local layout = vim.fn.system("xset -q | grep LED | awk '{print $10}' | cut -c5"):gsub("%s+", "")
	return layout == "0"
end

-- Notification setup
local function setup_notify(opts)
	if opts.notification.style == "minimal" then
		return function(msg)
			vim.cmd("echohl WarningMsg")
			vim.cmd(string.format('echo "%s"', msg:gsub('"', '\\"')))
			vim.cmd("echohl None")
		end
	else
		return function(msg)
			vim.notify(msg, opts.notification.level)
		end
	end
end

-- Key handling with debounce
local last_notify_time = 0
local function handle_key()
	if not is_english() then
		local current_time = vim.loop.now()
		-- Only notify if 500ms have passed since last notification
		if current_time - last_notify_time > 500 then
			if state.notify_fn then
				state.notify_fn(M.config.notification.message)
				last_notify_time = current_time
			end
		end
		return true
	end
	return false
end

-- Setup key handlers for normal mode
local function setup_normal_mode_handler()
	-- Use vim.on_key to catch ALL keypresses in normal mode
	vim.on_key(function(key)
		if vim.fn.mode() == "n" and handle_key() then
			-- Cancel the keypress by sending Escape
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
		end
	end)
end

-- Setup function
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", defaults, opts or {})

	-- Setup notification handler
	state.notify_fn = setup_notify(M.config)

	-- Create autogroup
	local group = vim.api.nvim_create_augroup("KeyboardGuard", { clear = true })

	-- Handle normal mode
	if M.config.modes.n then
		setup_normal_mode_handler()
	end

	-- Handle command mode
	if M.config.modes.c then
		vim.api.nvim_create_autocmd("CmdlineEnter", {
			group = group,
			callback = handle_key,
		})

		-- Also catch command-line inputs
		vim.api.nvim_create_autocmd("CmdlineChanged", {
			group = group,
			callback = function()
				if handle_key() then
					-- Exit command mode if non-English
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
				end
			end,
		})
	end

	-- Handle insert mode
	if M.config.modes.i then
		vim.api.nvim_create_autocmd("InsertCharPre", {
			group = group,
			callback = function()
				if handle_key() then
					vim.v.char = ""
				end
			end,
		})
	end

	-- Add debug commands
	vim.api.nvim_create_user_command("KGStatus", function()
		local layout = vim.fn.system("xset -q | grep LED | awk '{print $10}' | cut -c5"):gsub("%s+", "")
		local mode = vim.fn.mode()
		vim.notify(
			string.format(
				"Keyboard Guard Status:\nEnabled: %s\nCurrent Layout: %s\nCurrent Mode: %s",
				tostring(state.enabled),
				layout == "0" and "English" or "Non-English",
				mode
			)
		)
	end, {})
end

return M
