# Changelog

All notable changes to IconPickerKit are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Maintenance

- CI runs with Xcode 27.0 only; the Xcode 26.6 job is gone. The deployment minimum stays iOS 26 / macOS 26.
- The Mac-only demo app and media tool moved to `Demo`, a nested package (`./Demo/run-demo.sh`, `swift run --package-path Demo GenerateMedia`), and the root package no longer has an `IconPickerKitDemo` product. The package's tests now build for iOS, and CI runs them on the iOS Simulator as well as on macOS.
- `SymbolCatalog.ids` is derived from the grouped catalog, so each name is listed once, in catalog order. Tests that could not fail are gone; a new one checks that every catalog symbol exists on the running system.

### Added

- Return in the search field picks the first result, and in `IconPickerRow` also closes the popover, so the Mac row works from the keyboard.

### Changed

- **Breaking.** The kit ships no strings; every one comes from the app. `labels:` is required on `IconPickerView`, `IconPickerRow`, and the `IconCatalog` functions, and `IconPickerLabels` has no defaults for `color`, `icon`, `search`, `clear`, or `noIcons`. Group titles come from `groupTitle`, a closure over `IconGroup` that also names Suggestions, replacing `groupTitles` and `suggestions`. Color names come from `colorName`, a closure over `IconPickerColor`, replacing `colorNames`. `iconNames` and `iconKeywords` still override the catalog's built-in English icon metadata. `IconPickerLabels` is no longer `Equatable`.
- **Breaking.** `IconPickerColor` has no `name`: create one with `IconPickerColor(id:color:)` and name it in `IconPickerLabels.colorName`.
- **Breaking.** `String.isEmoji` is internal. As a public extension on `String` it collided with an app's own `isEmoji` that used a different rule. Use `IconKind.classify(_:) == .emoji`.
- Search filters on every keystroke. The 250 ms debounce is gone: filtering the whole catalog takes about 2 ms, so the pause only delayed results.

### Removed

- **Breaking.** `IconPickerLabels.english`, `IconGroup.title`, and the default title of `IconSection(group:items:title:)`: English text the kit supplied when an app passed none, which left localized apps with a mixed-language picker.
- **Breaking.** `SearchDebounce`, which only the search field used.
- **Breaking.** API that no app called:
  - `IconPickerView(suggestions:)` taking a `Task`, and `IconSuggestions.preload(hint:)` and `preload(hint:produce:)`. Pass `hint:`, or await `IconSuggestions.load` and pass the result as `suggestions:`.
  - `allowsCustomColor` on both pickers, with `IconPickerLabels.customColor` and `IconPickerColor.custom(_:)`, `customID`, and `isCustom`.
  - Per-group caps: `IconSectionLimit`, `IconCatalogPreset.compact` and `.work`, and the `limit:` argument. `IconCatalogPreset(groups:)` and `.all` stay, and `IconCatalogPreset.sections` is now `groups`.
  - The `symbols:` allow-list on both pickers and on `IconCatalog`.
  - `EmojiCatalog.search` and `EmojiCatalog.all`, `SymbolCatalog.search`, and the `groups:` overloads of `IconCatalog.sections`, `section(containing:)`, and `search`. Use `catalog: IconCatalogPreset(groups:)`.
  - `IconPickerLabels.emojis` and `symbols`, which the picker never showed.

### Fixed

- The on-device model returns at most eight suggestions. The limit was only prose in the prompt; the generation schema now enforces it.
- `IconPickerRow`'s popover opens with an empty search. The row kept the query, so the popover reopened filtered by the previous search.
- The icon the picker opens with always has a selected cell. One the catalog doesn't list, such as an icon picked from Suggestions earlier, was in no section; it now leads the first group. `IconCatalog.sections` and `search` take `selected:` for this, and `section(containing:)` returns that first group for such an icon.
- In the full picker the whole cell selects its icon. Only the glyph took the tap, so a tap near a cell's edge did nothing.

## [1.4.1] - 2026-10-20

### Changed

- Suggestions slide in at the top when they arrive, as in 1.3.0, instead of the picker reserving a row of placeholders while it waits. The picker assumes there are none, so with no suggestions the Suggestions group never shows. The group can wrap to a second row again, and it pushes the catalog down as it slides in; a scrolled catalog keeps its place.

### Removed

- `IconPickerLabels.noSuggestions`, which only the reserved row used.

## [1.4.0] - 2026-10-20

### Changed

- On-device model suggestions moved to the new `IconPickerKitIntelligence` product. `IconPickerKit` no longer links FoundationModels, which made every app initialize about 180 more system frameworks at launch even without suggestions. **Action needed** if you call `IconPickerView(hint:)`, `IconSuggestions.load(hint:)`, or `preload(hint:)`: add the `IconPickerKitIntelligence` product and `import IconPickerKitIntelligence`, or those calls stop compiling. The `produce:` variants and supplied suggestions stay in `IconPickerKit`.
- While suggestions load, the picker reserves one Suggestions row of placeholders from the first frame and fills it in place. The row shows as many suggestions as fit on one line.

### Added

- `IconPickerLabels.noSuggestions`, shown in the reserved row when the model answers late with nothing usable.

### Fixed

- Suggestions that arrived after the sheet settled (about 0.5–1.5 s with the on-device model) pushed the whole catalog down by up to two rows, moving the selected icon off screen and briefly dropping the last rows of the first section. Results now fill the reserved row in place, so nothing below it moves; an empty result within 250 ms of a request removes the row, and a later one shows No Suggestions.

## [1.3.0] - 2026-10-18

### Maintenance

- CI explicitly tests macOS and builds iOS Simulator with Xcode 26.6 and 27.0 while preserving OS 26 and Swift tools 6.2 minimums.

### Added

- Caller-localized group titles, icon names and search keywords, color names, Clear, and empty-catalog text. The row announces the selected icon's name.

### Fixed

- On iPhone and iPad the full picker scrolls to the selected icon on first appear again. Since 1.2.2 the scroll targeted an icon inside a section that had not laid out yet, so the catalog stayed at the top.

- The full picker and its pinned section headers share the same system surface, avoiding contrasting header stripes in iPad sheets.

- Touch swatches, Clear, and popover cells have 44-point minimum targets. Search and popover cells grow with text, and touch popovers no longer summon the keyboard automatically.

- Search reaches items beyond positive browse caps, trims whitespace, matches localized text, and displays a native empty state.

- Emoji classification uses Unicode presentation properties, including watch/hourglass, keycaps, flags, and joined emoji while respecting explicit text presentation.

- Replacing suggestion inputs refreshes an open picker, and cancelled requests cannot overwrite current suggestions. The preload example cancels work with its owner.

- Custom colors use a visible native ColorPicker; removed the retained global panel callback and opening no longer changes the selection.

- Negative catalog limits show no items instead of trapping; repeated groups use their first specification.

- Caller-supplied symbols outside the curated catalog appear once in the Symbols group.

## [1.2.5] - 2026-08-28

### Changed

- Catalog section titles stay pinned while that section is on screen.

## [1.2.4] - 2026-08-20

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
