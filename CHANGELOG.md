# Changelog

All notable changes to IconPickerKit are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Color chrome is hidden when the icon is an emoji. SF Symbols still show the swatches. The full picker expands it vertically; the row collapses it sideways.
- Default catalog leads with tintable groups. Smileys, Animals, and Food sit last.

## [1.2.3] - 2026-08-19

### Fixed

- Catalog section titles keep the shared horizontal inset before Suggestions appear.

## [1.2.2] - 2026-08-19

### Added

- Mac demo: `./scripts/run-demo.sh` launches a real app (Dock and Cmd-Tab). Delay suggestions 2 seconds to scroll before they land.

### Changed

- Color and search stay pinned above the catalog so they remain visible and do not overlap scrolling icons.
- Suggestions insert without moving a scrolled catalog. The expand animation only runs when the catalog is still at the top.
- Hover scale no longer clips color swatches or the row icon.
- On Mac, the rainbow custom swatch opens the system color panel on the first click.

## [1.2.1] - 2026-08-19

### Changed

- Search field is 36pt tall so body text has room inside the capsule.
- `IconPickerView` scrolls to the current icon on first layout, independently of suggestion loading, and animates the scroll. It skips the scroll when the icon is already on screen. Reduce Motion turns the animation off. Start `IconSuggestions.preload(hint:)` before presenting so the Suggestions group can already be there.
- Suggestions expand in from the top when the model returns, instead of popping in. Reduce Motion keeps a fade.

## [1.2.0] - 2026-08-19

### Added

- `hint` on `IconPickerView` asks the on-device Foundation Model for suggested icons. Usable results appear as a Suggestions group at the top; the group is omitted when the model is off or returns nothing. `IconSuggestions.preload(hint:)` and `load(hint:)`.
- Search Icons filters the mixed catalog, with debounce.
- `IconCatalogPreset` (`.all`, `.compact`, `.work`) sets groups, order, and per-group caps.
- `allowsCustomColor` appends a circular rainbow swatch that opens the system color picker. `IconPickerColor.custom(_:)`.
- README stills of `IconPickerView` and `IconPickerRow` in light and dark, including suggestions.

### Changed

- `IconPickerView` shows one meaning-grouped catalog of emoji and SF Symbols. No Emojis/Symbols mode switch and no hero preview.
- On Mac, embed `IconPickerRow` in the form. Do not present `IconPickerView` in a sheet.
- `IconPickerRow` is one row: Icon on the left, Color swatches after a divider, one mixed-catalog popover. Opening it focuses search; Escape dismisses.
- On Mac the row uses smaller swatches and buttons, help text, and a hover scale that turns off under Reduce Motion.
- Selected swatches use a concentric primary ring with a gap.
- Search is a capsule field on every platform.
- The color strip clips mid-swatch when it overflows, so the next color peeks.
- The full picker does not scroll to the current icon after the user has scrolled, and does not appear-scroll on a short Mac form.
- Default palette is one row of common hues.

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
