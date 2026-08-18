# IconPickerKit

A SwiftUI picker for a tint color plus an emoji or SF Symbol. Bind two values the consumer owns; present the view in a sheet, form, or navigation stack.

## Requirements

- iOS 26+ / macOS 26+
- Swift 6.2+

## Installation

The package is unpublished. Add it as a local Swift package:

```swift
dependencies: [
    .package(path: "../iconpickerkit"),
]
```

And to the target:

```swift
.product(name: "IconPickerKit", package: "IconPickerKit"),
```

In Xcode: **File > Add Package Dependencies… > Add Local…** and choose the `iconpickerkit` folder.

## Usage

```swift
import SwiftUI
import IconPickerKit

struct EditItemView: View {
    @State private var icon = "folder"
    @State private var color = IconPickerColor.blue

    var body: some View {
        NavigationStack {
            IconPickerView(icon: $icon, color: $color)
                .navigationTitle("Icon")
        }
    }
}
```

`icon` is either an emoji (`"🐶"`) or an SF Symbol name (`"folder"`). `color` is a swatch from the built-in palette.

Search and classification are also public if you want the catalogs without the view:

```swift
let hits = EmojiCatalog.search("dog")
let kind = IconKind.classify("🐶")  // .emoji
```

## License

MIT. See [LICENSE](LICENSE).
