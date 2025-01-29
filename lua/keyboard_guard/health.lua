local M = {}
-- Get the appropriate health module and its report functions
local health = vim.health or require("health")
local report_start = health.start or health.report_start
local report_ok = health.ok or health.report_ok
local report_warn = health.warn or health.report_warn
local report_error = health.error or health.report_error
local report_info = health.info or health.report_info

local function check_wsl_performance()
    if not is_wsl() then
        return
    end
    report_info("Running WSL performance checks...")
    -- Test PowerShell performance
    local start_time = vim.loop.hrtime()
    local ps_result = vim.fn.system(
        [[powershell.exe -NonInteractive -NoProfile -Command "[System.Windows.Forms.InputLanguage]::CurrentInputLanguage.Culture.Name"]]
    )
    local ps_time = (vim.loop.hrtime() - start_time) / 1000000
    if ps_time > 100 then
        report_warn(string.format("PowerShell layout check is slow (%.2fms). Using extended cache.", ps_time))
    else
        report_ok(string.format("PowerShell layout check is responsive (%.2fms)", ps_time))
    end

    -- Test Registry performance
    start_time = vim.loop.hrtime()
    local reg_result = vim.fn.system([[reg.exe query "HKEY_CURRENT_USER\\Keyboard Layout\\Preload" /v 1]])
    local reg_time = (vim.loop.hrtime() - start_time) / 1000000
    if reg_time > 100 then
        report_warn(string.format("Registry layout check is slow (%.2fms). Using as fallback only.", reg_time))
    else
        report_ok(string.format("Registry layout check is responsive (%.2fms)", reg_time))
    end
end

local function is_wsl()
    local output = vim.fn.system("uname -r")
    return output and output:lower():match("microsoft") ~= nil
end

local function check_environment()
    local env = vim.env
    -- Check for WSL first
    if is_wsl() then
        report_ok("WSL environment detected")
        -- Check PowerShell accessibility
        if vim.fn.executable("powershell.exe") == 1 then
            report_ok("PowerShell.exe is accessible from WSL")
        else
            report_warn("PowerShell.exe not found in WSL path, trying reg.exe fallback")
            if vim.fn.executable("reg.exe") == 1 then
                report_ok("reg.exe found, using registry fallback method")
            else
                report_error("Neither PowerShell.exe nor reg.exe accessible from WSL")
            end
        end
    elseif env.DISPLAY then
        report_ok("X11 environment detected")
        -- Check for xset
        if vim.fn.executable("xset") == 1 then
            report_ok("xset command found")
        else
            report_warn("xset command not found, X11 layout detection may not work")
        end
    elseif env.WAYLAND_DISPLAY then
        report_ok("Wayland environment detected")
        -- Check for swaymsg
        if vim.fn.executable("swaymsg") == 1 then
            report_ok("swaymsg command found")
        else
            report_info("swaymsg not found, using fallback detection method")
        end
    elseif vim.fn.has("win32") == 1 then
        report_ok("Windows environment detected")
        -- Check PowerShell
        if vim.fn.executable("powershell") == 1 then
            report_ok("PowerShell is available")
        else
            report_error("PowerShell not found, plugin will not work properly")
        end
    elseif vim.fn.has("mac") == 1 then
        report_ok("macOS environment detected")
        -- Check defaults command
        if vim.fn.executable("defaults") == 1 then
            report_ok("defaults command found")
        else
            report_error("defaults command not found, plugin will not work properly")
        end
    else
        report_warn("Unknown environment, layout detection may not work")
    end
end

function M.check()
    report_start("keyboard-guard.nvim")
    -- Check Neovim version
    if vim.fn.has("nvim-0.8.0") == 1 then
        report_ok("Neovim version >= 0.8.0")
    else
        report_error("Neovim version must be >= 0.8.0")
    end
    -- Check environment and dependencies
    check_environment()
    -- Check WSL performance if applicable
    check_wsl_performance()
end

return M
