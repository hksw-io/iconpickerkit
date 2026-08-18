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

@Test func emptyEmojiQueryReturnsFullCatalog() {
    #expect(EmojiCatalog.search("").count == EmojiCatalog.all.count)
}

@Test func symbolSearchHitMatchesName() {
    let query = "folder"
    let results = SymbolCatalog.search(query)
    #expect(!results.isEmpty)
    #expect(results.allSatisfy { $0.lowercased().contains(query) })
}

@Test func symbolSearchMissIsEmpty() {
    #expect(SymbolCatalog.search("zzzznotasymbol").isEmpty)
}

@Test func emptySymbolQueryReturnsFullCatalog() {
    #expect(SymbolCatalog.search("") == SymbolCatalog.ids)
}

@Test func debounceAppliesLatestQueryAfterPause() {
    var debounce = SearchDebounce(interval: .milliseconds(250))
    debounce.push("d", at: .milliseconds(0))
    debounce.push("do", at: .milliseconds(10))
    debounce.push("dog", at: .milliseconds(20))
    debounce.flush(at: .milliseconds(20))
    #expect(debounce.applied != "d")
    #expect(debounce.applied != "do")
    debounce.flush(at: .milliseconds(270))
    #expect(debounce.applied == "dog")
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
    #expect(IconPickerLabels.english.search == "Search Icons")
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

@Test @MainActor func inlineRowCompiles() {
    _ = IconPickerRow(icon: .constant("folder"), color: .constant(.blue))
}

@Test @MainActor func inlineRowAcceptsPaletteAndLabels() {
    _ = IconPickerRow(
        icon: .constant("🐶"),
        color: .constant(.blue),
        colors: [.blue, .red],
        labels: IconPickerLabels(color: "Färg"))
}

@Test @MainActor func pickerStoresCallerSymbols() {
    let symbols = ["star", "heart"]
    let view = IconPickerView(icon: .constant("star"), color: .constant(.blue), symbols: symbols)
    #expect(view.symbols == symbols)
}

@Test @MainActor func pickerStoresCallerCatalog() {
    let catalog = IconCatalogPreset(groups: [.home, .smileys])
    let view = IconPickerView(icon: .constant("folder"), color: .constant(.blue), catalog: catalog)
    #expect(view.catalog == catalog)
}

@Test func presetLimitCapsSection() {
    let full = IconCatalog.sections(groups: [.smileys]).first?.items.count ?? 0
    let limited = IconCatalog.sections(
        catalog: IconCatalogPreset([IconSectionLimit(.smileys, limit: 3)]))
        .first?.items.count ?? 0
    #expect(limited == min(3, full))
}

@Test func compactPresetIsSmallerThanAll() {
    let allCount = IconCatalog.sections(catalog: .all).flatMap(\.items).count
    let compactCount = IconCatalog.sections(catalog: .compact).flatMap(\.items).count
    #expect(compactCount < allCount)
}

@Test func workPresetOnlyUsesItsGroups() {
    let allowed: Set<IconGroup> = [.work, .home, .objects]
    #expect(IconCatalog.sections(catalog: .work).allSatisfy { allowed.contains($0.group) })
}

@Test @MainActor func pickerDefaultsToSymbolCatalog() {
    let view = IconPickerView(icon: .constant("folder"), color: .constant(.blue))
    #expect(view.symbols == SymbolCatalog.ids)
}

@Test @MainActor func inlineRowStoresCallerSymbols() {
    let symbols = ["star", "heart"]
    let view = IconPickerRow(icon: .constant("star"), color: .constant(.blue), symbols: symbols)
    #expect(view.symbols == symbols)
}

@Test func stackGapIsSharedAroundSearch() {
    #expect(IconPickerLayout.spacingAboveSearch == IconPickerLayout.stackSpacing)
    #expect(IconPickerLayout.spacingBelowSearch == IconPickerLayout.stackSpacing)
}

@Test func sectionGapMatchesStackGap() {
    #expect(IconPickerLayout.sectionSpacing == IconPickerLayout.stackSpacing)
}

@Test func controlsShareOneInset() {
    #expect(IconPickerLayout.searchInset == IconPickerLayout.horizontalInset)
    #expect(IconPickerLayout.modeInset == IconPickerLayout.horizontalInset)
    #expect(IconPickerLayout.labelInset == IconPickerLayout.horizontalInset)
    #expect(IconPickerLayout.catalogInset == IconPickerLayout.horizontalInset)
    #expect(IconPickerLayout.colorStripInset == IconPickerLayout.horizontalInset)
}

@Test func searchMatchesModeControlHeight() {
    #expect(IconPickerLayout.searchHeight == IconPickerLayout.controlHeight)
    #expect(IconPickerLayout.modeHeight == IconPickerLayout.controlHeight)
}

@Test func mixedCatalogIdleHasNamedSectionsAndBothKinds() {
    let sections = IconCatalog.search("")
    #expect(sections.count > 1)
    let values = sections.flatMap(\.items).map(\.value)
    #expect(values.contains { $0.isEmoji })
    #expect(values.contains { !$0.isEmoji })
    #expect(Set(sections.map(\.title)).count == sections.count)
}

@Test func mixedCatalogSearchHitMatchesNameKeywordsOrId() {
    let query = "dog"
    let items = IconCatalog.search(query).flatMap(\.items)
    #expect(!items.isEmpty)
    #expect(items.allSatisfy { $0.matches(query) })
}

@Test func mixedCatalogSearchMissIsEmpty() {
    #expect(IconCatalog.search("zzzznotanicon").isEmpty)
}

@Test func mixedCatalogAssignsEveryBuiltInSymbol() {
    let assigned = Set(
        IconCatalog.sections().flatMap(\.items).map(\.value).filter { !$0.isEmoji })
    #expect(assigned == Set(SymbolCatalog.ids))
}

@Test func catalogSectionContainsKnownSymbol() {
    let section = IconCatalog.section(containing: "folder")
    #expect(section?.items.contains { $0.value == "folder" } == true)
}

@Test func catalogSectionContainsKnownEmoji() {
    let section = IconCatalog.section(containing: "🐶")
    #expect(section?.items.contains { $0.value == "🐶" } == true)
}

@Test func catalogSectionMissIsNil() {
    #expect(IconCatalog.section(containing: "zzzznotanicon") == nil)
}

@Test func catalogRespectsGroupOrder() {
    let sections = IconCatalog.sections(groups: [.work, .smileys])
    #expect(sections.map(\.group) == [.work, .smileys])
}

@Test func catalogOmitsUnlistedGroups() {
    let sections = IconCatalog.sections(groups: [.home])
    #expect(sections.allSatisfy { $0.group == .home })
}

@Test func searchPreservesCallerGroupOrder() {
    let sections = IconCatalog.search("a", groups: [.work, .smileys, .home])
    let order = sections.map(\.group)
    #expect(order == order.sorted { lhs, rhs in
        let rank: [IconGroup] = [.work, .smileys, .home]
        return rank.firstIndex(of: lhs)! < rank.firstIndex(of: rhs)!
    })
}
