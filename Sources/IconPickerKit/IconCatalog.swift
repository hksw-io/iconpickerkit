import Foundation

/// An emoji or SF Symbol in the mixed catalog.
public struct IconItem: Identifiable, Sendable, Equatable {
    public let value: String
    public let name: String
    public let keywords: [String]

    public var id: String { self.value }

    public init(value: String, name: String, keywords: [String] = []) {
        self.value = value
        self.name = name
        self.keywords = keywords
    }

    public func matches(_ query: String) -> Bool {
        let needle = query.lowercased()
        return self.name.lowercased().contains(needle)
            || self.value.lowercased().contains(needle)
            || self.keywords.contains { $0.lowercased().contains(needle) }
    }
}

/// A meaning-themed group the consumer can reorder or omit.
public enum IconGroup: String, CaseIterable, Sendable, Identifiable {
    case smileys
    case people
    case animals
    case food
    case activity
    case health
    case work
    case home
    case places
    case nature
    case objects
    case symbols
    case suggestions

    public var id: String { self.rawValue }

    public var title: String {
        switch self {
        case .smileys: "Smileys"
        case .people: "People"
        case .animals: "Animals"
        case .food: "Food"
        case .activity: "Activity"
        case .health: "Health"
        case .work: "Work"
        case .home: "Home"
        case .places: "Places"
        case .nature: "Nature"
        case .objects: "Objects"
        case .symbols: "Symbols"
        case .suggestions: "Suggestions"
        }
    }
}

/// A meaning-themed group of mixed emoji and SF Symbols.
public struct IconSection: Identifiable, Sendable, Equatable {
    public let group: IconGroup
    public let items: [IconItem]

    public var id: String { self.group.rawValue }
    public var title: String { self.group.title }

    public init(group: IconGroup, items: [IconItem]) {
        self.group = group
        self.items = items
    }
}

/// How many items to show from one group. `limit` nil means the whole group.
public struct IconSectionLimit: Sendable, Equatable {
    public var group: IconGroup
    public var limit: Int?

    public init(_ group: IconGroup, limit: Int? = nil) {
        self.group = group
        self.limit = limit
    }
}

/// Group order, membership, and per-group caps.
public struct IconCatalogPreset: Sendable, Equatable {
    public var sections: [IconSectionLimit]

    public init(_ sections: [IconSectionLimit]) {
        self.sections = sections
    }

    public init(groups: [IconGroup], limit: Int? = nil) {
        self.sections = groups.map { IconSectionLimit($0, limit: limit) }
    }

    public static let all = IconCatalogPreset(
        groups: IconGroup.allCases.filter { $0 != .suggestions })

    public static let compact = IconCatalogPreset([
        IconSectionLimit(.people, limit: 8),
        IconSectionLimit(.work, limit: 12),
        IconSectionLimit(.home, limit: 8),
        IconSectionLimit(.places, limit: 8),
        IconSectionLimit(.objects, limit: 12),
        IconSectionLimit(.symbols, limit: 8),
    ])

    public static let work = IconCatalogPreset([
        IconSectionLimit(.work, limit: 16),
        IconSectionLimit(.home, limit: 12),
        IconSectionLimit(.objects, limit: 12),
    ])
}

/// One catalog of emoji and SF Symbols, grouped by meaning.
public enum IconCatalog {
    /// Sections for `symbols` using `catalog` order, membership, and caps.
    public static func sections(
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        suggestions: [IconItem] = []) -> [IconSection]
    {
        let allowed = Set(symbols)
        var result = catalog.sections.compactMap { spec in
            let (emojis, symbolIDs) = self.content(for: spec.group)
            var mixed =
                emojis.map(Self.emojiItem)
                + symbolIDs.filter { allowed.contains($0) }.map(Self.symbolItem)
            if let limit = spec.limit {
                mixed = Array(mixed.prefix(limit))
            }
            return mixed.isEmpty ? nil : IconSection(group: spec.group, items: mixed)
        }
        if !suggestions.isEmpty {
            result.insert(IconSection(group: .suggestions, items: suggestions), at: 0)
        }
        return result
    }

    /// The meaning section that holds `value`, if any.
    public static func section(
        containing value: String,
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        suggestions: [IconItem] = []) -> IconSection?
    {
        self.sections(symbols: symbols, catalog: catalog, suggestions: suggestions)
            .first { section in
                section.items.contains { $0.value == value }
            }
    }

    /// Empty query returns every requested section. A miss returns no sections.
    public static func search(
        _ query: String,
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        suggestions: [IconItem] = []) -> [IconSection]
    {
        let all = self.sections(symbols: symbols, catalog: catalog, suggestions: suggestions)
        guard !query.isEmpty else { return all }
        return all.compactMap { section in
            let items = section.items.filter { $0.matches(query) }
            return items.isEmpty ? nil : IconSection(group: section.group, items: items)
        }
    }

    public static func sections(
        symbols: [String] = SymbolCatalog.ids,
        groups: [IconGroup],
        suggestions: [IconItem] = []) -> [IconSection]
    {
        self.sections(
            symbols: symbols,
            catalog: IconCatalogPreset(groups: groups),
            suggestions: suggestions)
    }

    public static func section(
        containing value: String,
        symbols: [String] = SymbolCatalog.ids,
        groups: [IconGroup],
        suggestions: [IconItem] = []) -> IconSection?
    {
        self.section(
            containing: value,
            symbols: symbols,
            catalog: IconCatalogPreset(groups: groups),
            suggestions: suggestions)
    }

    public static func search(
        _ query: String,
        symbols: [String] = SymbolCatalog.ids,
        groups: [IconGroup],
        suggestions: [IconItem] = []) -> [IconSection]
    {
        self.search(
            query,
            symbols: symbols,
            catalog: IconCatalogPreset(groups: groups),
            suggestions: suggestions)
    }

    private static func emojiItem(_ item: EmojiItem) -> IconItem {
        IconItem(value: item.emoji, name: item.name, keywords: item.keywords)
    }

    private static func symbolItem(_ id: String) -> IconItem {
        IconItem(
            value: id,
            name: id.replacingOccurrences(of: ".", with: " "),
            keywords: id.split(separator: ".").map(String.init))
    }

    private static func content(for group: IconGroup) -> ([EmojiItem], [String]) {
        switch group {
        case .smileys:
            return (EmojiCatalog.smileys, [])
        case .people:
            return (
                EmojiCatalog.gestures,
                [
                    "person", "person.2", "person.3", "person.crop.circle",
                    "hand.raised", "hand.thumbsup", "figure.walk", "figure.run",
                    "brain", "brain.head.profile",
                ])
        case .animals:
            return (EmojiCatalog.animals, [])
        case .food:
            return (EmojiCatalog.food, ["fork.knife"])
        case .activity:
            return (
                EmojiCatalog.activities,
                [
                    "trophy", "medal", "target", "gamecontroller", "die.face.5",
                    "puzzlepiece", "theatermasks", "music.note", "music.note.list",
                    "music.quarternote.3", "music.mic", "guitars",
                    "play", "pause", "stop", "forward", "backward", "speaker.wave.2",
                ])
        case .health:
            return (
                [],
                [
                    "heart", "heart.circle", "heart.text.square",
                    "waveform.path.ecg", "waveform.path.ecg.rectangle",
                    "cross.case", "stethoscope", "pills", "pill", "bandage",
                    "lungs", "cross", "hands.sparkles",
                ])
        case .work:
            return (
                [],
                [
                    "rectangle.stack", "sparkles.rectangle.stack", "books.vertical",
                    "text.book.closed", "book", "book.closed", "bookmark",
                    "graduationcap", "character", "character.bubble",
                    "textformat.abc", "textformat.123", "textformat.size",
                    "note.text", "note.text.badge.plus", "doc.text",
                    "doc.text.magnifyingglass", "doc.on.doc", "doc.append",
                    "doc.badge.plus", "doc.richtext", "list.number", "list.bullet",
                    "list.bullet.rectangle", "list.bullet.clipboard", "list.clipboard",
                    "square.and.pencil", "pencil", "calendar", "calendar.badge.clock",
                    "calendar.badge.plus", "clock", "hourglass", "timer", "stopwatch",
                    "alarm", "function", "sum", "x.squareroot", "percent", "atom",
                    "chart.bar", "chart.line.uptrend.xyaxis",
                    "chart.line.downtrend.xyaxis", "chart.pie", "chart.bar.xaxis",
                    "dollarsign.circle", "bitcoinsign.circle", "creditcard",
                    "banknote", "briefcase", "building.columns",
                ])
        case .home:
            return (
                [],
                [
                    "house", "folder", "tray", "tray.and.arrow.down", "archivebox",
                    "tag", "clipboard", "lightbulb", "key", "lock", "lock.open",
                    "shield", "gear", "gearshape",
                ])
        case .places:
            return (
                [],
                [
                    "globe", "globe.americas", "globe.europe.africa",
                    "globe.asia.australia", "mappin.and.ellipse", "mappin.circle",
                    "map", "map.circle", "location", "location.square",
                    "location.north", "binoculars", "airplane", "airplane.departure",
                    "car", "bus", "tram", "bicycle", "ferry",
                ])
        case .nature:
            return (
                [],
                [
                    "leaf", "leaf.fill", "tree", "sun.max", "moon", "cloud",
                    "cloud.sun", "umbrella", "snowflake", "drop", "flame",
                    "rainbow", "sparkles", "wand.and.stars", "bolt",
                    "bolt.badge.clock",
                ])
        case .objects:
            return (
                EmojiCatalog.objects,
                [
                    "paperclip", "pin", "link", "paperplane", "phone", "envelope",
                    "hammer", "wrench", "screwdriver", "laptopcomputer",
                    "desktopcomputer", "keyboard", "tv", "server.rack",
                    "externaldrive", "icloud", "network",
                    "antenna.radiowaves.left.and.right", "wifi", "battery.100",
                    "powerplug", "iphone", "ipad", "applewatch", "headphones",
                    "cpu", "faceid", "camera", "video", "photo",
                    "square.and.arrow.up", "square.and.arrow.down",
                    "square.grid.2x2", "square.grid.3x2", "line.3.horizontal",
                    "shippingbox", "suitcase", "backpack", "paintbrush",
                    "paintbrush.pointed", "paintpalette", "ruler", "curlybraces",
                ])
        case .suggestions:
            return ([], [])
        case .symbols:
            return (
                EmojiCatalog.symbols,
                [
                    "star", "star.circle", "checkmark", "checkmark.circle",
                    "checkmark.seal", "text.bubble", "bubble.left.and.bubble.right",
                    "arrow.left", "arrow.right", "arrow.up", "arrow.down",
                    "arrow.clockwise", "arrow.counterclockwise",
                    "chevron.left", "chevron.right", "chevron.up", "chevron.down",
                ])
        }
    }
}
