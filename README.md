# keyboard-guard.nvim

A Neovim plugin that prevents unintended actions when typing in non-English keyboard layouts.

## Features

- Lightweight and performant
- Supports multiple environments (X11, Wayland, Windows, macOS)
- Prevents accidental commands in non-English layouts
- Minimal configuration required
- No external dependencies

## Requirements

- Neovim >= 0.8.0

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "yourusername/keyboard-guard.nvim",
    event = "VeryLazy",
    opts = {
        -- your configuration
    }
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'yourusername/keyboard-guard.nvim',
    config = function()
        require('keyboard_guard').setup({
            -- your configuration
        })
    end
}
```

## Configuration

```lua
require('keyboard_guard').setup({
    protect_cmdline = true,  -- protect command line (default: true)
    protect_normal = true,   -- protect normal mode (default: true)
})
```

## How it Works

The plugin detects your current keyboard layout using native system commands and prevents potentially destructive actions when a non-English layout is active. It's designed to be lightweight and only loads what's necessary for your specific environment.

## Supported Environments

- X11/Xorg
- Wayland (including Sway)
- Windows
- macOS

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
