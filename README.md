# IconPickerKit

A SwiftUI picker for a tint color plus an emoji or SF Symbol. Bind two values the consumer owns; present the view in a sheet, form, or navigation stack.

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
