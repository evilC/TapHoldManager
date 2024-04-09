# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

## ##[2.0] - 2024-04-09

### Added

* Added support for AHK v2

* Implemented PauseHotkey / ResumeHotkey for InterceptionTapHold

### Changed

### Deprecated

### Removed

### Fixed

## [1.5] - 2020-04-30

### Added

- Add support for context-specific hotkeys (THM only takes effect when a specific window is active)  
- Add Pause / Resume hotkeys functionality  

### Changed

- InterceptionTapHold now accepts an instance of AutoHotInterception and a Device ID  
  This allows you to use AutoHotInterception's GetDeviceIdFromHandle method to get device ID

## [1.4] - 2019-02-28

### Added

- Added MaxTaps parameter to support always firing callback after a fixed number of taps / holds

## [1.3] - 2018-10-09

### Added

- TapHoldManager now works with Joystick Buttons (eg 1Joy1)

## [1.2] - 2018-04-02

### Changed

- Updates the AutoHotInterception addon to support AHI 3.x

## [1.1] - 2018-03-22

### Added

- Added an additional holdTime parameter to control the amount of time a key must be held to be considered a hold.

## [1.0] - 2018-03-06

### Added

- Inital version
