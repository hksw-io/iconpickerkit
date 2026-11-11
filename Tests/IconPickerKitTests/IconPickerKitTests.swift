#if os(macOS)
import AppKit
#endif
import SwiftUI
import Testing
@testable import IconPickerKit
import IconPickerKitIntelligence

extension IconPickerLabels {
    /// English stand-ins for the strings an app passes. The kit has none of its own.
    static let fixture = IconPickerLabels(
        color: "Color",
        icon: "Icon",
        search: "Search Icons",
        clear: "Clear",
        noIcons: "No Icons",
        groupTitle: { $0.rawValue.capitalized },
        colorName: { $0.id.capitalized })
}

@Test func localizedCatalogNamesAndKeywordsPreserveIdentifiersAndHeadings() {
    var labels = IconPickerLabels.fixture
    labels.groupTitle = { $0 == .home ? "Hem" : $0.rawValue }
    labels.iconNames = ["folder": "Mapp"]
    labels.iconKeywords = ["folder": ["dokument"]]
    let sections = IconCatalog.search("DOKUMENT", catalog: IconCatalogPreset(groups: [.home]), labels: labels)
    #expect(sections.first?.title == "Hem")
    #expect(sections.first?.items.first?.value == "folder")
    #expect(sections.first?.items.first?.name == "Mapp")
    #expect(IconCatalog.search("folder", labels: labels).flatMap(\.items)
        .contains { $0.value == "folder" && $0.name == "Mapp" })
    let suggested = IconCatalog.sections(suggestions: [.init(value: "folder", name: "folder")], labels: labels)
    #expect(suggested.first?.items.first?.name == "Mapp")
}

@Test func searchTrimsQueriesWithoutAddingExcludedGroups() {
    let catalog = IconCatalogPreset(groups: [.home])
    #expect(IconCatalog.search(" ", catalog: catalog, labels: .fixture).map(\.group) == [.home])
    #expect(IconCatalog.search("  folder  ", catalog: catalog, labels: .fixture).flatMap(\.items).contains { $0.value == "folder" })
    #expect(IconCatalog.search("book", catalog: catalog, labels: .fixture).isEmpty)
    #expect(IconItem(value: "folder", name: "Böcker").matches("BOCKER"))
}

@Test func emojiClassificationUsesUnicodePresentationInsteadOfCodePointRanges() {
    for value in ["⌚", "⌛", "1️⃣", "🇸🇪", "👨‍👩‍👧", "👍🏽", "❤️"] {
        #expect(IconKind.classify(value) == .emoji)
        #expect(value.isSingleEmoji)
    }
    for value in ["1", "#", "1.square", "1\u{0301}", "⌚\u{FE0E}"] {
        #expect(IconKind.classify(value) == .symbol)
    }
    #expect(!"🇸🇪🇫🇮".isSingleEmoji)
}

@Test @MainActor func suggestionRequestsRefreshAndDiscardCancelledWaiters() async {
    let result = IconSuggestions(items: [.init(value: "folder", name: "Folder")])
    let request = IconSuggestionRequest(hint: "docs", ready: .empty)
    #expect(request != IconSuggestionRequest(hint: "new", ready: .empty))
    #expect(request != IconSuggestionRequest(hint: "docs", ready: result))

    let started = AsyncStream<Void>.makeStream()
    let gate = AsyncStream<Void>.makeStream()
    let waiter = Task {
        await request.value(produce: { _ in
            started.continuation.yield()
            for await _ in gate.stream {}
            return ["folder"]
        })
    }
    for await _ in started.stream { break }
    waiter.cancel()
    gate.continuation.finish()
    #expect(await waiter.value == nil)
    #expect(await IconSuggestionRequest(hint: nil, ready: result).value(produce: { _ in [] }) == result)
    #expect(await IconSuggestionRequest(hint: nil, ready: .empty).value(produce: { _ in [] }) == .empty)
}

@Test func repeatedGroupsAppearOnce() {
    let sections = IconCatalog.sections(catalog: IconCatalogPreset(groups: [.home, .work, .home]), labels: .fixture)
    #expect(sections.map(\.group) == [.home, .work])
}

@Test func classifyEmoji() {
    #expect(IconKind.classify("🐶") == .emoji)
}

@Test func classifySymbol() {
    #expect(IconKind.classify("folder") == .symbol)
}

@Test func colorChromeIsNotOfferedForEmoji() {
    #expect(!IconKind.offersColorChrome(for: "🐶"))
}

@Test func colorChromeIsOfferedForSymbol() {
    #expect(IconKind.offersColorChrome(for: "folder"))
}

@Test func colorChromeAnimationRespectsReduceMotion() {
    #expect(IconPickerScrollPolicy.colorChromeAnimation(reduceMotion: true) == nil)
    #expect(IconPickerScrollPolicy.colorChromeAnimation(reduceMotion: false) != nil)
}

@Test @MainActor func publicPickerCompiles() {
    _ = IconPickerView(icon: .constant("folder"), color: .constant(.blue), labels: .fixture)
    _ = IconPickerView(icon: .constant("🐶"), color: .constant(.blue), labels: .fixture)
}

@Test func defaultPaletteIncludesBlue() {
    #expect(IconPickerColor.all.contains { $0.id == IconPickerColor.blue.id })
}

@Test func defaultPaletteFillsARow() {
    #expect(IconPickerColor.all.count >= 8)
}

@Test @MainActor func pickerAcceptsCustomPalette() {
    let brand = IconPickerColor(id: "brand", color: .indigo)
    _ = IconPickerView(
        icon: .constant("folder"),
        color: .constant(brand),
        colors: [brand, .blue],
        labels: .fixture)
}

@Test @MainActor func inlineRowCompiles() {
    _ = IconPickerRow(icon: .constant("folder"), color: .constant(.blue), labels: .fixture)
    _ = IconPickerRow(icon: .constant("🐶"), color: .constant(.blue), labels: .fixture)
}

@Test @MainActor func pickerStoresCallerCatalog() {
    let catalog = IconCatalogPreset(groups: [.home, .smileys])
    let view = IconPickerView(icon: .constant("folder"), color: .constant(.blue), catalog: catalog, labels: .fixture)
    #expect(view.catalog == catalog)
}

@Test func sectionGapMatchesStackGap() {
    #expect(IconPickerLayout.sectionSpacing == IconPickerLayout.stackSpacing)
}

@Test func touchTargetsGrowWithoutExpandingMacControls() {
    #if os(macOS)
    #expect(IconPickerLayout.hitSize(for: 20) == 20)
    #expect(IconPickerLayout.autofocusRowSearch)
    #else
    for size: CGFloat in [20, 24, 32, 44, 60] {
        #expect(IconPickerLayout.hitSize(for: size) >= 44)
        #expect(IconPickerLayout.hitSize(for: size) >= size)
    }
    #expect(IconPickerLayout.rowCellSize >= 44)
    #expect(!IconPickerLayout.autofocusRowSearch)
    #endif
}

@Test func mixedCatalogIdleHasNamedSectionsAndBothKinds() {
    let sections = IconCatalog.search("", labels: .fixture)
    #expect(sections.count > 1)
    let values = sections.flatMap(\.items).map(\.value)
    #expect(values.contains { $0.isEmoji })
    #expect(values.contains { !$0.isEmoji })
    #expect(Set(sections.map(\.title)).count == sections.count)
}

@Test func mixedCatalogSearchHitMatchesNameKeywordsOrId() {
    let query = "dog"
    let items = IconCatalog.search(query, labels: .fixture).flatMap(\.items)
    #expect(!items.isEmpty)
    #expect(items.allSatisfy { $0.matches(query) })
}

@Test func mixedCatalogSearchMissIsEmpty() {
    #expect(IconCatalog.search("zzzznotanicon", labels: .fixture).isEmpty)
}

@Test func mixedCatalogAssignsEveryBuiltInSymbol() {
    let assigned = Set(
        IconCatalog.sections(labels: .fixture).flatMap(\.items).map(\.value).filter { !$0.isEmoji })
    #expect(assigned == Set(SymbolCatalog.ids))
}

@Test func catalogSectionContainsKnownSymbol() {
    let section = IconCatalog.section(containing: "folder", labels: .fixture)
    #expect(section?.items.contains { $0.value == "folder" } == true)
}

@Test func catalogSectionContainsKnownEmoji() {
    let section = IconCatalog.section(containing: "🐶", labels: .fixture)
    #expect(section?.items.contains { $0.value == "🐶" } == true)
}

@Test func catalogSectionMissIsNil() {
    #expect(IconCatalog.section(containing: "zzzznotanicon", labels: .fixture) == nil)
}

@Test func selectedIconOutsideTheCatalogLeadsTheFirstGroup() {
    let catalog = IconCatalogPreset(groups: [.home, .work])
    let plain = IconCatalog.sections(catalog: catalog, labels: .fixture)
    let sections = IconCatalog.sections(
        catalog: catalog, suggestions: [.init(value: "🥖", name: "🥖")], labels: .fixture, selected: "🇫🇷")
    #expect(sections.map(\.group) == [.suggestions, .home, .work])
    #expect(sections[1].items.map(\.value) == ["🇫🇷"] + plain[0].items.map(\.value))
    #expect(sections[2] == plain[1])
    #expect(IconCatalog.section(containing: "🇫🇷", catalog: catalog, labels: .fixture)?.group == .home)
    #expect(IconCatalog.sections(catalog: catalog, labels: .fixture, selected: "folder") == plain)
    #expect(IconCatalog.sections(catalog: catalog, labels: .fixture, selected: "not an icon") == plain)
}

@Test func catalogRespectsGroupOrder() {
    let sections = IconCatalog.sections(catalog: IconCatalogPreset(groups: [.work, .smileys]), labels: .fixture)
    #expect(sections.map(\.group) == [.work, .smileys])
}

@Test func defaultCatalogLeadsWithTintableGroups() {
    let groups = IconCatalog.sections(catalog: .all, labels: .fixture).map(\.group)
    let tintable: Set<IconGroup> = [.work, .home, .health, .places, .nature]
    let emojiHeavy: Set<IconGroup> = [.smileys, .animals, .food]
    let lastTintable = groups.lastIndex { tintable.contains($0) }
    let firstEmojiHeavy = groups.firstIndex { emojiHeavy.contains($0) }
    #expect(lastTintable != nil && firstEmojiHeavy != nil)
    #expect(lastTintable! < firstEmojiHeavy!)
    #expect(groups.prefix(5).allSatisfy { tintable.contains($0) })
}

@Test func catalogOmitsUnlistedGroups() {
    let sections = IconCatalog.sections(catalog: IconCatalogPreset(groups: [.home]), labels: .fixture)
    #expect(sections.allSatisfy { $0.group == .home })
}

@Test func searchPreservesCallerGroupOrder() {
    let sections = IconCatalog.search("a", catalog: IconCatalogPreset(groups: [.work, .smileys, .home]), labels: .fixture)
    let order = sections.map(\.group)
    #expect(order == order.sorted { lhs, rhs in
        let rank: [IconGroup] = [.work, .smileys, .home]
        return rank.firstIndex(of: lhs)! < rank.firstIndex(of: rhs)!
    })
}

@Test func cannedSuggestionsAppearAheadOfRegularGroups() async {
    let loaded = await IconSuggestions.load(hint: "French") { _ in ["🇫🇷", "flag"] }
    #expect(loaded.items.map(\.value) == ["🇫🇷", "flag"])
    let sections = IconCatalog.sections(suggestions: loaded.items, labels: .fixture)
    #expect(sections.first?.group == .suggestions)
    #expect(sections.first?.items.map(\.value) == ["🇫🇷", "flag"])
    #expect(sections.dropFirst().first?.group != .suggestions)
    #expect(IconCatalog.section(containing: "🇫🇷", suggestions: loaded.items, labels: .fixture)?.group == .suggestions)
}

@Test func emptyHintYieldsNoExtraGroup() async {
    let loaded = await IconSuggestions.load(hint: "   ") { _ in ["🇫🇷"] }
    #expect(loaded.isEmpty)
    #expect(IconCatalog.sections(suggestions: loaded.items, labels: .fixture).first?.group != .suggestions)
}

@Test func unavailableSuggestionsYieldNoExtraGroup() async {
    let loaded = await IconSuggestions.load(hint: "French") { _ in [] }
    #expect(loaded.isEmpty)
    #expect(IconCatalog.sections(suggestions: loaded.items, labels: .fixture).first?.group != .suggestions)
}

@Test func failedSuggestionsYieldNoExtraGroup() async {
    struct Boom: Error {}
    let loaded = await IconSuggestions.load(hint: "French") { _ in throw Boom() }
    #expect(loaded.isEmpty)
    #expect(IconCatalog.sections(suggestions: loaded.items, labels: .fixture).first?.group != .suggestions)
}

@Test func unusableSuggestionsYieldNoExtraGroup() async {
    let loaded = await IconSuggestions.load(hint: "French") { _ in
        ["hello", "not an icon", "🇫🇷🥖", ""]
    }
    #expect(loaded.isEmpty)
    #expect(IconCatalog.sections(suggestions: loaded.items, labels: .fixture).first?.group != .suggestions)
}

@Test @MainActor func pickerAcceptsFinishedSuggestionsWithoutRunningBody() async {
    let loaded = await IconSuggestions.load(hint: "French") { _ in ["🇫🇷"] }
    let view = IconPickerView(
        icon: .constant("folder"),
        color: .constant(.blue),
        suggestions: loaded,
        labels: .fixture)
    let sections = IconCatalog.sections(suggestions: view.readySuggestions.items, labels: .fixture)
    #expect(view.readySuggestions.items.map(\.value) == ["🇫🇷"])
    #expect(sections.first?.group == .suggestions)
    #expect(sections.first?.items.map(\.value) == ["🇫🇷"])
}

@Test func defaultCatalogOmitsEmptySuggestionsGroup() {
    #expect(IconCatalog.sections(labels: .fixture).allSatisfy { $0.group != .suggestions })
}

@Test @MainActor func popoverSearchAutofocuses() {
    let field = IconPickerSearchField(
        text: .constant(""),
        prompt: "Search Icons",
        autofocus: true,
        clearLabel: "Clear")
    #expect(field.autofocus)
}

@Test func scrollToSelectionSkipsAfterUserScrolls() {
    #expect(
        !IconPickerScrollPolicy.shouldScrollToSelection(userHasScrolled: true, shortForm: false))
}

@Test func scrollToSelectionSkipsShortMacForm() {
    #expect(
        !IconPickerScrollPolicy.shouldScrollToSelection(userHasScrolled: false, shortForm: true))
}

@Test func scrollToSelectionRunsOnTallFormBeforeUserScrolls() {
    #expect(IconPickerScrollPolicy.shouldScrollToSelection(userHasScrolled: false, shortForm: false))
}

@Test func appearScrollDoesNotWaitForSuggestions() {
    #expect(
        IconPickerScrollPolicy.shouldScrollToSelection(
            userHasScrolled: false,
            selectionIsVisible: false,
            shortForm: false))
}

@Test func appearScrollSkipsWhenSelectionIsOnScreen() {
    #expect(
        !IconPickerScrollPolicy.shouldScrollToSelection(
            userHasScrolled: false,
            selectionIsVisible: true,
            shortForm: false))
}

@Test func appearScrollAnimationRespectsReduceMotion() {
    #expect(IconPickerScrollPolicy.scrollAnimation(reduceMotion: true) == nil)
    #expect(IconPickerScrollPolicy.scrollAnimation(reduceMotion: false) != nil)
}

@Test func suggestionAppearAnimationRespectsReduceMotion() {
    #expect(IconPickerScrollPolicy.suggestionAppearAnimation(reduceMotion: true) == nil)
    #expect(IconPickerScrollPolicy.suggestionAppearAnimation(reduceMotion: false) != nil)
}

@Test func suggestionAppearAnimationSkipsWhenCatalogHasScrolled() {
    #expect(
        IconPickerScrollPolicy.suggestionAppearAnimation(
            reduceMotion: false,
            catalogIsAtTop: false) == nil)
    #expect(
        IconPickerScrollPolicy.suggestionAppearAnimation(
            reduceMotion: false,
            catalogIsAtTop: true) != nil)
}

@Test func catalogAtTopAccountsForInset() {
    #expect(IconPickerScrollPolicy.catalogIsAtTop(offsetY: 0, insetTop: 0))
    #expect(IconPickerScrollPolicy.catalogIsAtTop(offsetY: 8, insetTop: 0))
    #expect(!IconPickerScrollPolicy.catalogIsAtTop(offsetY: 40, insetTop: 0))
    #expect(IconPickerScrollPolicy.catalogIsAtTop(offsetY: 20, insetTop: 16))
    #expect(!IconPickerScrollPolicy.catalogIsAtTop(offsetY: 32, insetTop: 16))
}

@Test func macFullPickerUsesShortFormPolicy() {
    #if os(macOS)
    #expect(IconPickerScrollPolicy.isShortForm)
    #expect(!IconPickerScrollPolicy.shouldScrollToSelection(userHasScrolled: false))
    #else
    #expect(!IconPickerScrollPolicy.isShortForm)
    #endif
}

@Test func hoverScaleRespectsReduceMotion() {
    #expect(IconPickerHover.scale(isHovered: true, reduceMotion: true) == 1)
    #expect(IconPickerHover.scale(isHovered: false, reduceMotion: false) == 1)
    #expect(IconPickerHover.scale(isHovered: true, reduceMotion: false) == IconPickerHover.amount)
}

@Test func hoverOverflowContainsScaledControl() {
    for size: CGFloat in [20, 32, 36, 44] {
        let overflow = IconPickerHover.overflow(for: size)
        #expect(size + 2 * overflow >= size * IconPickerHover.amount)
    }
}

@Test func coreLibraryDoesNotImportFoundationModels() throws {
    // Linking FoundationModels initializes ~180 system images at launch, so only
    // IconPickerKitIntelligence may import it.
    let sources = URL(filePath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "Sources/IconPickerKit")
    let files = try FileManager.default.contentsOfDirectory(at: sources, includingPropertiesForKeys: nil)
    #expect(!files.isEmpty)
    for file in files {
        let source = try String(contentsOf: file, encoding: .utf8)
        #expect(!source.contains("import FoundationModels"), "\(file.lastPathComponent)")
    }
}

#if os(macOS)
/// SwiftUI has no hit-test API, so this clicks a hosted cell in its corner, clear of the glyph.
/// Mac only: a unit test cannot synthesize a touch on iOS.
@Test @MainActor func fullPickerCellIsTappableOutsideItsGlyph() throws {
    _ = NSApplication.shared
    var taps = 0
    let cell = IconPickerCell(
        item: IconItem(value: "folder", name: "Folder"), isSelected: false, tint: .blue, size: 44, font: 22)
    {
        taps += 1
    }
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 44, height: 44),
        styleMask: [.borderless],
        backing: .buffered,
        defer: false)
    window.isReleasedWhenClosed = false
    window.contentView = NSHostingView(rootView: cell)
    // Events only reach a window that is on screen.
    window.orderFrontRegardless()
    defer { window.orderOut(nil) }
    window.contentView?.layoutSubtreeIfNeeded()
    for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
        window.sendEvent(try #require(NSEvent.mouseEvent(
            with: type,
            location: NSPoint(x: 3, y: 3),
            modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber,
            context: nil,
            eventNumber: 0,
            clickCount: 1,
            pressure: type == .leftMouseDown ? 1 : 0)))
    }
    #expect(taps == 1)
}
#endif
