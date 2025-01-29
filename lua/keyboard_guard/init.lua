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

-- Increase cache duration for WSL since layout changes are less frequent
local WSL_CACHE_DURATION = 1000 -- 1 second for WSL
local DEFAULT_CACHE_DURATION = 100 -- 100ms for other environments

-- Optimized WSL layout detection
local wsl_layout_detectors = {
    -- Fast check using PowerShell
    powershell = function()
        return safe_system(
            [[powershell.exe -NonInteractive -NoProfile -Command "[System.Windows.Forms.InputLanguage]::CurrentInputLanguage.Culture.Name"]]
        )
    end,

    -- Fallback using Registry
    registry = function()
        return safe_system([[reg.exe query "HKEY_CURRENT_USER\\Keyboard Layout\\Preload" /v 1]])
    end,
}

-- Cache both the environment check and the detector results
local cached_wsl_detector = {
    method = nil,
    last_check = 0,
    last_result = true,
}

-- Safe system command execution
local function safe_system(cmd)
    local ok, result = pcall(vim.fn.system, cmd)
    if not ok then
        return nil
    end
    return result
end

local function is_wsl()
    local output = safe_system("uname -r")
    return output and output:lower():match("microsoft") ~= nil
end

-- Environment detection
local function detect_env()
    if state.env then
        return state.env
    end

    -- Check for WSL first
    if is_wsl() then
        state.env = "wsl"
    elseif vim.fn.has("win32") == 1 then
        state.env = "windows"
    elseif vim.fn.has("mac") == 1 then
        state.env = "macos"
    elseif vim.env.WAYLAND_DISPLAY then
        -- Only detect Wayland if not in WSL
        state.env = "wayland"
    elseif vim.env.DISPLAY then
        state.env = "x11"
    else
        state.env = "unknown"
    end

    return state.env
end

-- Layout detectors for different environments
local layout_detectors = {
    x11 = function()
        local result = safe_system("xset -q | grep LED | awk '{print $10}' | cut -c5")
        return result and result:gsub("%s+", "") == "0"
    end,

    wayland = function()
        if vim.fn.executable("swaymsg") == 1 then
            local result = safe_system([[swaymsg -t get_inputs | grep "xkb_active_layout_name" | head -1 | cut -d'"' -f4]])
            if result then
                return result:match("^[Ee]nglish") or result:match("^US") or result:match("^ASCII")
            end
        end
        -- Try generic Wayland method (works on GNOME)
        if vim.fn.executable("gdbus") == 1 then
            local result = safe_system([[
                gdbus call --session \
                    --dest org.gnome.Shell \
                    --object-path /org/gnome/Shell \
                    --method org.gnome.Shell.Eval \
                    "imports.ui.status.keyboard.getInputSourceManager().currentSource.index"
            ]])
            return result and result:match("0")
        end
        return true
    end,

    windows = function()
        -- Use a more reliable PowerShell command for layout detection
        local cmd = [[powershell -NoProfile -NonInteractive -Command "[System.Globalization.CultureInfo]::CurrentUICulture.Name"]]
        local result = safe_system(cmd)

        -- Add debug logging
        if not result then
            vim.notify("KeyboardGuard: Failed to execute PowerShell command", vim.log.levels.DEBUG)
            return true -- Fail safe
        end

        -- Check for common English locale codes
        local is_english = result:match("^en%-") ~= nil
        return is_english
    end,

    macos = function()
        local result = safe_system(
            [[defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep "KeyboardLayout Name" | cut -d'"' -f4]]
        )
        if result then
            return result:match("US") or result:match("ABC") or result:match("^English")
        end
        return true
    end,

    wsl = function()
        local current_time = get_timestamp()

        -- Use cached result if fresh enough
        if (current_time - cached_wsl_detector.last_check) < WSL_CACHE_DURATION then
            return cached_wsl_detector.last_result
        end

        local result = false

        -- Try cached method first
        if cached_wsl_detector.method then
            result = wsl_layout_detectors[cached_wsl_detector.method]()
            if result then
                cached_wsl_detector.last_result = result:match("^en") or result:match("0+[48]09")
                cached_wsl_detector.last_check = current_time
                return cached_wsl_detector.last_result
            end
        end

        -- Try PowerShell first
        result = wsl_layout_detectors.powershell()
        if result then
            cached_wsl_detector.method = "powershell"
            cached_wsl_detector.last_result = result:match("^en")
            cached_wsl_detector.last_check = current_time
            return cached_wsl_detector.last_result
        end

        -- Fallback to Registry
        result = wsl_layout_detectors.registry()
        if result then
            cached_wsl_detector.method = "registry"
            cached_wsl_detector.last_result = result:match("0+[48]09")
            cached_wsl_detector.last_check = current_time
            return cached_wsl_detector.last_result
        end

        -- If both methods fail, cache the failure and default to allowing input
        cached_wsl_detector.last_result = true
        cached_wsl_detector.last_check = current_time
        vim.notify("KeyboardGuard: Layout detection failed, defaulting to pass-through", vim.log.levels.WARN)
        return true
    end,

    -- Fallback detector always returns true to avoid blocking input
    unknown = function()
        vim.notify("KeyboardGuard: Unable to detect keyboard layout, defaulting to pass-through", vim.log.levels.WARN)
        return true
    end,
}

local function get_timestamp()
    -- Use milliseconds since startup instead of absolute time
    return vim.loop.hrtime() / 1000000
end

-- Layout detection
local function is_english()
    if not state.enabled then
        return true
    end

    -- Initialize detector if needed
    if not state.detector then
        local env = detect_env()
        state.detector = layout_detectors[env]
        vim.notify("KeyboardGuard: Initialized for " .. env .. " environment", vim.log.levels.INFO)
    end

    return state.detector()
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

-- Key handling with improved debounce
local last_notify_time = get_timestamp()
local layout_cache = { time = get_timestamp(), result = true }
local CACHE_DURATION = 100 -- milliseconds
local NOTIFICATION_COOLDOWN = 500 -- milliseconds

-- Update the cache duration based on environment
local function get_cache_duration()
    return state.env == "wsl" and WSL_CACHE_DURATION or DEFAULT_CACHE_DURATION
end

-- Cached layout check
local function check_layout()
    local current_time = get_timestamp()
    local cache_duration = get_cache_duration()

    -- Use cached result if it's fresh enough
    if current_time - layout_cache.time < cache_duration then
        return layout_cache.result
    end

    -- Update cache
    layout_cache.time = current_time
    layout_cache.result = is_english()
    return layout_cache.result
end

-- Improved key handling
local function handle_key()
    -- Check if we should show notification
    local current_time = vim.loop.now()
    local should_notify = (current_time - last_notify_time) > NOTIFICATION_COOLDOWN

    -- Check layout with caching
    local is_eng = check_layout()

    if not is_eng then
        -- Only notify if enough time has passed
        if should_notify and state.notify_fn then
            state.notify_fn(M.config.notification.message)
            last_notify_time = current_time
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

-- Command mode handling with immediate feedback
local function setup_command_mode_handler(group)
    -- Handle command mode entry
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = group,
        callback = function()
            -- Reset notification timer on mode change
            last_notify_time = 0
            return handle_key()
        end,
    })

    -- Handle command-line inputs
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

local function init_timers()
    last_notify_time = vim.loop.now()
    layout_cache = { time = vim.loop.now(), result = true }
end

-- Setup function
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", defaults, opts or {})

    -- Initialize timers properly
    init_timers()

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
        setup_command_mode_handler(group)
    end

    -- Handle insert mode
    if M.config.modes.i then
        vim.api.nvim_create_autocmd("InsertCharPre", {
            group = group,
            callback = function()
                -- Reset notification timer on mode change
                last_notify_time = 0
                if handle_key() then
                    vim.v.char = ""
                end
            end,
        })
    end

    -- Reset cache on mode changes
    vim.api.nvim_create_autocmd({ "ModeChanged", "FocusGained" }, {
        group = group,
        callback = function()
            layout_cache.time = 0 -- Force layout recheck
            last_notify_time = 0 -- Reset notification cooldown
        end,
    })

    -- Add debug command
    vim.api.nvim_create_user_command("KGDebug", function()
        local current_layout = check_layout()
        local mode = vim.fn.mode()
        local current_time = vim.loop.now()
        vim.notify(
            string.format(
                "Keyboard Guard Debug:\n"
                    .. "Enabled: %s\n"
                    .. "Current Layout: %s\n"
                    .. "Current Mode: %s\n"
                    .. "Time since last notification: %dms",
                tostring(state.enabled),
                current_layout and "English" or "Non-English",
                mode,
                current_time - last_notify_time
            )
        )
    end, {})
end

return M
