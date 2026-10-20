/// Picker copy and catalog metadata. Pass localized strings without changing persisted IDs.
public struct IconPickerLabels: Equatable, Sendable {
    public var color: String
    public var icon: String
    public var emojis: String
    public var symbols: String
    public var search: String
    public var customColor: String
    public var suggestions: String
    public var clear: String
    public var noIcons: String
    public var groupTitles: [IconGroup: String]
    public var iconNames: [String: String]
    public var iconKeywords: [String: [String]]
    public var colorNames: [String: String]

    public init(
        color: String = "Color",
        icon: String = "Icon",
        emojis: String = "Emojis",
        symbols: String = "Symbols",
        search: String = "Search Icons",
        customColor: String = "Custom",
        suggestions: String = "Suggestions",
        clear: String = "Clear",
        noIcons: String = "No Icons",
        groupTitles: [IconGroup: String] = [:],
        iconNames: [String: String] = [:],
        iconKeywords: [String: [String]] = [:],
        colorNames: [String: String] = [:])
    {
        self.color = color
        self.icon = icon
        self.emojis = emojis
        self.symbols = symbols
        self.search = search
        self.customColor = customColor
        self.suggestions = suggestions
        self.clear = clear
        self.noIcons = noIcons
        self.groupTitles = groupTitles
        self.iconNames = iconNames
        self.iconKeywords = iconKeywords
        self.colorNames = colorNames
    }

    func title(for group: IconGroup) -> String {
        self.groupTitles[group] ?? (group == .suggestions ? self.suggestions : group.title)
    }

    func localized(_ item: IconItem) -> IconItem {
        IconItem(
            value: item.value,
            name: self.iconNames[item.value] ?? item.name,
            keywords: item.keywords + (self.iconKeywords[item.value] ?? []))
    }

    public static let english = IconPickerLabels()
}
