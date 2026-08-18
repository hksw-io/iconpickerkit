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
