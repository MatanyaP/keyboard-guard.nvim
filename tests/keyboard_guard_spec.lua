local assert = require("luassert")
local mock = require("luassert.mock")

describe("keyboard-guard", function()
	local keyboard_guard
	local mock_notify

	before_each(function()
		-- Load the module fresh for each test
		package.loaded["keyboard_guard"] = nil
		keyboard_guard = require("keyboard_guard")

		-- Mock vim.notify
		mock_notify = mock(vim.notify, true)
	end)

	after_each(function()
		-- Clean up mocks
		mock.revert(mock_notify)
	end)

	describe("setup", function()
		it("should load with default config", function()
			keyboard_guard.setup({})
			assert.is_true(true) -- Basic loading test
		end)

		it("should merge user config with defaults", function()
			keyboard_guard.setup({
				notification = {
					message = "Test message",
				},
			})
			-- Add assertions for config merging
		end)
	end)

	describe("environment detection", function()
		it("should detect the current environment", function()
			keyboard_guard.setup({})
			-- Add environment-specific tests
		end)
	end)

	describe("layout detection", function()
		it("should handle X11 layout detection", function()
			-- Mock system commands and test X11 detection
		end)

		it("should handle Wayland layout detection", function()
			-- Mock system commands and test Wayland detection
		end)

		it("should handle macOS layout detection", function()
			-- Mock system commands and test macOS detection
		end)

		it("should handle Windows layout detection", function()
			-- Mock system commands and test Windows detection
		end)
	end)

	describe("key handling", function()
		it("should block keys in normal mode when non-English layout detected", function()
			-- Test key blocking in normal mode
		end)

		it("should allow keys in normal mode when English layout detected", function()
			-- Test key passing in normal mode
		end)
	end)
end)
