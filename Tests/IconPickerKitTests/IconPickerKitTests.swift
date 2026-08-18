import SwiftUI
import Testing
@testable import IconPickerKit

@Test func searchHitMatchesNameOrKeywords() {
    let query = "dog"
    let results = EmojiCatalog.search(query)
    #expect(!results.isEmpty)
    #expect(
        results.allSatisfy { item in
            item.name.lowercased().contains(query)
                || item.keywords.contains { $0.lowercased().contains(query) }
        })
}

@Test func searchMissIsEmpty() {
    #expect(EmojiCatalog.search("zzzznotanemoji").isEmpty)
}

@Test func classifyEmoji() {
    #expect(IconKind.classify("🐶") == .emoji)
}

@Test func classifySymbol() {
    #expect(IconKind.classify("folder") == .symbol)
}

@Test @MainActor func publicPickerCompiles() {
    _ = IconPickerView(icon: .constant("folder"), color: .constant(.blue))
}

@Test func primarySwatchNameIsLabel() {
    #expect(IconPickerColor.primary.name == "Label")
}

@Test func customColorKeepsCallerIdentity() {
    let brand = IconPickerColor(id: "brand", name: "Brand", color: .indigo)
    #expect(brand.id == "brand")
    #expect(brand.name == "Brand")
}

@Test func defaultPaletteIncludesBlue() {
    #expect(IconPickerColor.all.contains { $0.id == IconPickerColor.blue.id })
}

@Test @MainActor func pickerAcceptsCustomPalette() {
    let brand = IconPickerColor(id: "brand", name: "Brand", color: .indigo)
    _ = IconPickerView(
        icon: .constant("folder"),
        color: .constant(brand),
        colors: [brand, .blue])
}

@Test func englishLabelsAreTheDefaults() {
    #expect(IconPickerLabels.english.color == "Color")
    #expect(IconPickerLabels.english.icon == "Icon")
    #expect(IconPickerLabels.english.emojis == "Emojis")
    #expect(IconPickerLabels.english.symbols == "Symbols")
    #expect(IconPickerLabels.english.search == "Search")
}

@Test func customLabelsKeepCallerCopy() {
    let labels = IconPickerLabels(
        color: "Färg",
        icon: "Ikon",
        emojis: "Emoji",
        symbols: "Symboler",
        search: "Sök")
    #expect(labels.color == "Färg")
    #expect(labels.icon == "Ikon")
    #expect(labels.emojis == "Emoji")
    #expect(labels.symbols == "Symboler")
    #expect(labels.search == "Sök")
}

@Test @MainActor func pickerAcceptsLabels() {
    _ = IconPickerView(
        icon: .constant("folder"),
        color: .constant(.blue),
        labels: IconPickerLabels(color: "Färg", search: "Sök"))
}
