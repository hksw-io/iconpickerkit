# IconPickerKit

A SwiftUI picker for a tint color plus an emoji or SF Symbol. Bind two values the consumer owns.

- `IconPickerView` — a full picker for a sheet or pushed screen.
- `IconPickerRow` — compact swatches and popovers for a form.

## Preview

<p>
  <img src="Docs/Media/iconpickerkit-view-light.png" width="240" alt="IconPickerView in light mode: a Color header and swatches, Search Icons, and the Smileys section.">
  <img src="Docs/Media/iconpickerkit-view-dark.png" width="240" alt="IconPickerView in dark mode with the same Color header, search field, and Smileys section.">
</p>

`IconPickerView`. Present it in a sheet; you own Done.

<p>
  <img src="Docs/Media/iconpickerkit-row-light.png" width="360" alt="IconPickerRow in a light form: a Color row of swatches with blue selected, and an Icon row with an emoji button and a selected folder button.">
  <img src="Docs/Media/iconpickerkit-row-dark.png" width="360" alt="IconPickerRow in a dark form with the same color swatches and icon buttons.">
</p>

`IconPickerRow` in a form.

## Requirements

- iOS 26+ / macOS 26+
- Swift 6.2+

## Installation

Internal to the `hksw-io` org. Add:

```swift
.package(url: "https://github.com/hksw-io/iconpickerkit.git", from: "1.0.0")
```

```swift
.product(name: "IconPickerKit", package: "IconPickerKit"),
```

In Xcode: **File > Add Package Dependencies…** and enter the URL above. You need access to the org.

## Usage

Sheet with a Done button. Bindings update live; you own dismissal.

```swift
import SwiftUI
import IconPickerKit

struct EditItemView: View {
    @State private var icon = "folder"
    @State private var color = IconPickerColor.blue
    @State private var showingPicker = false

    var body: some View {
        Button("Icon") { self.showingPicker = true }
            .sheet(isPresented: self.$showingPicker) {
                NavigationStack {
                    IconPickerView(icon: self.$icon, color: self.$color)
                        .navigationTitle("Icon")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { self.showingPicker = false }
                            }
                        }
                }
            }
    }
}
```

`icon` is either an emoji (`"🐶"`) or an SF Symbol name (`"folder"`). Persist `icon` and `color.id`.

One mixed catalog, grouped by meaning (People, Work, Home, …). Search Icons filters the whole library. Keystrokes debounce for 250 ms.

Put Smileys last (or hide a group) with `groups:`:

```swift
IconPickerView(
    icon: $icon,
    color: $color,
    groups: IconGroup.allCases.filter { $0 != .smileys } + [.smileys])
```

### In a form

```swift
Form {
    IconPickerRow(icon: self.$icon, color: self.$color)
}
```

### Palette, symbols, and labels

```swift
let brand = IconPickerColor(id: "brand", name: "Brand", color: .indigo)

IconPickerView(
    icon: self.$icon,
    color: self.$color,
    colors: [.blue, brand],
    symbols: ["folder", "star", "heart"],
    labels: IconPickerLabels(
        color: String(localized: "picker.color"),
        icon: String(localized: "picker.icon"),
        emojis: String(localized: "picker.emojis"),
        symbols: String(localized: "picker.symbols"),
        search: String(localized: "picker.search")))
```

`IconPickerRow` takes the same `colors`, `symbols`, and `labels` arguments.

Search and classification are also public if you want the catalogs without the view:

```swift
let hits = EmojiCatalog.search("dog")
let kind = IconKind.classify("🐶")  // .emoji
```

## Local development

```sh
swift test
swift run GenerateMedia
```

`GenerateMedia` rewrites the README stills in `Docs/Media`.

## License

MIT. See [LICENSE](LICENSE).
