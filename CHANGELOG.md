# Changelog

All notable changes to IconPickerKit are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `hint` on `IconPickerView` asks the on-device Foundation Model for suggested icons. Usable results appear as a Suggestions group at the top; the group is omitted when the model is off or returns nothing.
- `IconSuggestions.preload(hint:)` starts that work before the picker appears.
- README stills of `IconPickerView` and `IconPickerRow` in light and dark.
- Platform search on both pickers, with debounce. The same query filters emojis or symbols.
- Search is an in-catalog SwiftUI field so it is visible without a nav bar.
- One stack gap, inset, and control height for the full picker’s label, mode control, search, and catalog.
- Section-to-section spacing uses that same gap, so Color → Icon matches Icon → controls.
- `SymbolCatalog.search` and `SearchDebounce`.

### Changed

- README: on Mac, embed `IconPickerRow` in the form. Do not present `IconPickerView` in a sheet.
- On Mac, the compact row uses smaller swatches and buttons, help text, and a hover scale that turns off under Reduce Motion.
- Selected swatch rings use a contrasting stroke instead of white, so yellow and the label swatch stay visible in dark mode.
- Mac search uses the system rounded-border field. iOS keeps the in-content capsule.
- `IconPickerRow` opens one mixed emoji and SF Symbol catalog popover.
- Opening that popover focuses search. Escape dismisses it.
- On Mac, custom color is a visible system color well. iOS keeps the spectrum swatch.
- The full picker does not scroll to the current icon after the user has scrolled, and does not appear-scroll on a short Mac form.
- `IconPickerView` shows one meaning-grouped catalog of emoji and SF Symbols. No Emojis/Symbols mode switch.
- Preview is cell-sized; search sits under the color strip, above the catalog.
- No hero preview. On iPhone the picker scrolls the current icon into view unless the user has already scrolled.
- `IconCatalog.search` returns named sections; an empty query is the full catalog.
- `IconCatalogPreset` (`.all`, `.compact`, `.work`) sets groups, order, and per-group caps.
- `allowsCustomColor` appends a spectrum swatch on the far right that opens the system color picker. `IconPickerColor.custom(_:)`.
- Default palette is one row of common hues. Teal, cyan, brown, and label stay as extras.
- The color strip clips mid-swatch when it overflows, so the next color peeks.
- The emoji/symbol control hides its extra macOS picker title. The section header already names it.

## [1.1.0] - 2026-08-18

### Added

- `IconPickerColor` is a value you can construct. Pass `colors:` to `IconPickerView` to use a brand palette.
- `IconPickerLabels` localizes the chrome. Pass `labels:` or keep `.english`.
- `IconPickerRow` — compact swatches + emoji/symbol popovers for forms.
- Pass `symbols:` on either picker to use your own SF Symbol list.

### Fixed

- The `.primary` swatch is named "Label". It follows the system label color, so "Black" was a lie in dark mode.

## [1.0.0] - 2026-08-18

Extracted from Swiftflip's deck/folder icon picker.

### Added

- `IconPickerView` — bind an icon string and an `IconPickerColor`.
- `EmojiCatalog.search` and `IconKind.classify`.
- Built-in color palette, curated emoji catalog, and SF Symbol catalog.
