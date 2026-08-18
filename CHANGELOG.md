# Changelog

All notable changes to IconPickerKit are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `IconPickerColor` is a value you can construct. Pass `colors:` to `IconPickerView` to use a brand palette.
- `IconPickerLabels` localizes the chrome. Pass `labels:` or keep `.english`.
- `IconPickerRow` — compact swatches + emoji/symbol popovers for forms.

### Fixed

- The `.primary` swatch is named "Label". It follows the system label color, so "Black" was a lie in dark mode.

## [1.0.0] - 2026-08-18

Extracted from Swiftflip's deck/folder icon picker.

### Added

- `IconPickerView` — bind an icon string and an `IconPickerColor`.
- `EmojiCatalog.search` and `IconKind.classify`.
- Built-in color palette, curated emoji catalog, and SF Symbol catalog.
