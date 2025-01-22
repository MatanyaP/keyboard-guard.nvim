# Contributing to keyboard-guard.nvim

Thank you for considering contributing to keyboard-guard.nvim!

## Development Setup

1. Fork the repository
2. Clone your fork:

```bash
git clone https://github.com/MatanyaP/keyboard-guard.nvim
cd keyboard-guard.nvim
```

3. Create a new branch:

```bash
git checkout -b feature/your-feature-name
```

4. Install development dependencies:

```bash
# If you use packer.nvim for Neovim plugin management
git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
```

## Running Tests

Tests are written using plenary.nvim. To run them:

```bash
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

## Coding Standards

- Follow the existing code style
- Use LuaLS annotations for function documentation
- Keep functions small and focused
- Add tests for new functionality
- Update documentation when needed

## Pull Request Process

1. Update tests and documentation for any new features
2. Update the CHANGELOG.md
3. Ensure all tests pass and linting checks succeed
4. Create a Pull Request with a clear title and description

## Code Review Process

1. Maintainers will review your PR
2. Changes may be requested
3. Once approved, maintainers will merge your PR

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
