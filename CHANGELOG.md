# Changelog

All notable changes to keyboard-guard.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Initial development

## [0.1.3] - 2025-01-29
### Fixed
- Significantly improved WSL input latency
- Optimized layout detection caching for WSL
- Added performance monitoring to health checks
- Implemented smart fallback for slow layout detection methods

## [0.1.2] - 2025-01-29
### Fixed
- Added proper WSL environment detection
- Implemented WSL-specific keyboard layout detection with fallback methods
- Fixed incorrect Wayland detection in WSL environments
- Fixed timestamp calculation for notifications
- Enhanced health checks for WSL environments
- Added PowerShell and Registry fallback methods for WSL

## [0.1.1] - 2025-01-23
### Fixed
- Fixed freezing issue in WSL environments
- Fixed delayed notification queuing
- Improved layout detection across different environments
- Added proper caching and debouncing for better performance

## [0.1.0] - 2025-01-22
### Added
- Initial release
- Support for X11, Wayland, macOS, and Windows
- Layout detection for multiple environments
- Normal mode protection
- Command mode protection
- Insert mode protection (optional)
- Customizable notifications
- Debug commands
