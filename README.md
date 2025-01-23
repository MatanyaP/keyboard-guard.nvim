# keyboard-guard.nvim

A Neovim plugin that prevents unintended actions when typing in non-English keyboard layouts. Works across multiple environments (X11, Wayland, Windows, macOS) and provides immediate feedback when typing with a non-English layout.

## ✨ Features

- Lightweight and performant
- Cross-platform support (X11, Wayland, Windows, macOS)
- Prevents accidental commands in non-English layouts
- Minimal configuration required
- No external dependencies for most environments

## ⚡️ Requirements

- Neovim >= 0.8.0
- Environment-specific requirements:
  - X11: `xset` (usually pre-installed)
  - Wayland: `swaymsg` (for Sway) or `gdbus` (for GNOME)
  - Windows: PowerShell (pre-installed)
  - macOS: No additional requirements

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "MatanyaP/keyboard-guard.nvim",
    event = "VeryLazy",
    opts = {
        -- your configuration
    }
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'MatanyaP/keyboard-guard.nvim',
    config = function()
        require('keyboard_guard').setup({
            -- your configuration
        })
    end
}
```

## ⚙️ Configuration

```lua
require('keyboard_guard').setup({
    notification = {
        enabled = true,     -- enable notifications
        style = "minimal",  -- "minimal" or "default"
        message = "Please switch to English layout!",
    },
    modes = {
        n = true,  -- protect normal mode
        i = false, -- don't protect insert mode
        c = true,  -- protect command mode
    },
})
```

## 🚀 Usage

Once installed and configured, the plugin works automatically:

- In normal mode: prevents executing commands when in non-English layout
- In command mode: prevents entering commands with non-English layout
- Shows notifications when attempting to type in protected modes with non-English layout

Debug commands:

```vim
:KGDebug     " Show debug information about current layout
:KGStatus    " Show current plugin status
```

## 🔧 How It Works

The plugin detects your current keyboard layout using native system commands and prevents potentially destructive actions when a non-English layout is active. It's designed to be lightweight and only loads what's necessary for your specific environment.

## 🔧 Troubleshooting

If you experience any issues:

1. Run `:checkhealth keyboard-guard` to verify your environment setup
2. Use `:KGDebug` to get detailed information about the current state
3. Try setting `notification.style = "default"` for better visibility during debugging
4. For WSL users: Make sure PowerShell is accessible from your WSL environment

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guide](CONTRIBUTING.md) for more details.

## 📄 License

MIT
