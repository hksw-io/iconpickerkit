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

/// A meaning-themed group of mixed emoji and SF Symbols.
public struct IconSection: Identifiable, Sendable, Equatable {
    public let title: String
    public let items: [IconItem]

    public var id: String { self.title }

    public init(title: String, items: [IconItem]) {
        self.title = title
        self.items = items
    }
}

/// One catalog of emoji and SF Symbols, grouped by meaning.
public enum IconCatalog {
    /// Sections for `symbols` (defaults to the built-in SF Symbol list).
    public static func sections(symbols: [String] = SymbolCatalog.ids) -> [IconSection] {
        let allowed = Set(symbols)
        return self.blueprint.compactMap { title, emojis, symbolIDs in
            let mixed =
                emojis.map(Self.emojiItem)
                + symbolIDs.filter { allowed.contains($0) }.map(Self.symbolItem)
            return mixed.isEmpty ? nil : IconSection(title: title, items: mixed)
        }
    }

    /// Empty query returns every section. A miss returns no sections.
    public static func search(_ query: String, symbols: [String] = SymbolCatalog.ids) -> [IconSection] {
        let all = self.sections(symbols: symbols)
        guard !query.isEmpty else { return all }
        return all.compactMap { section in
            let items = section.items.filter { $0.matches(query) }
            return items.isEmpty ? nil : IconSection(title: section.title, items: items)
        }
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

    private static let blueprint: [(String, [EmojiItem], [String])] = [
        ("Smileys", EmojiCatalog.smileys, []),
        (
            "People",
            EmojiCatalog.gestures,
            [
                "person", "person.2", "person.3", "person.crop.circle",
                "hand.raised", "hand.thumbsup", "figure.walk", "figure.run",
                "brain", "brain.head.profile",
            ]),
        ("Animals", EmojiCatalog.animals, []),
        ("Food", EmojiCatalog.food, ["fork.knife"]),
        (
            "Activity",
            EmojiCatalog.activities,
            [
                "trophy", "medal", "target", "gamecontroller", "die.face.5",
                "puzzlepiece", "theatermasks", "music.note", "music.note.list",
                "music.quarternote.3", "music.mic", "guitars",
                "play", "pause", "stop", "forward", "backward", "speaker.wave.2",
            ]),
        (
            "Health",
            [],
            [
                "heart", "heart.circle", "heart.text.square",
                "waveform.path.ecg", "waveform.path.ecg.rectangle",
                "cross.case", "stethoscope", "pills", "pill", "bandage",
                "lungs", "cross", "hands.sparkles",
            ]),
        (
            "Work",
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
            ]),
        (
            "Home",
            [],
            [
                "house", "folder", "tray", "tray.and.arrow.down", "archivebox",
                "tag", "clipboard", "lightbulb", "key", "lock", "lock.open",
                "shield", "gear", "gearshape",
            ]),
        (
            "Places",
            [],
            [
                "globe", "globe.americas", "globe.europe.africa",
                "globe.asia.australia", "mappin.and.ellipse", "mappin.circle",
                "map", "map.circle", "location", "location.square",
                "location.north", "binoculars", "airplane", "airplane.departure",
                "car", "bus", "tram", "bicycle", "ferry",
            ]),
        (
            "Nature",
            [],
            [
                "leaf", "leaf.fill", "tree", "sun.max", "moon", "cloud",
                "cloud.sun", "umbrella", "snowflake", "drop", "flame",
                "rainbow", "sparkles", "wand.and.stars", "bolt",
                "bolt.badge.clock",
            ]),
        (
            "Objects",
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
            ]),
        (
            "Symbols",
            EmojiCatalog.symbols,
            [
                "star", "star.circle", "checkmark", "checkmark.circle",
                "checkmark.seal", "text.bubble", "bubble.left.and.bubble.right",
                "arrow.left", "arrow.right", "arrow.up", "arrow.down",
                "arrow.clockwise", "arrow.counterclockwise",
                "chevron.left", "chevron.right", "chevron.up", "chevron.down",
            ]),
    ]
}
