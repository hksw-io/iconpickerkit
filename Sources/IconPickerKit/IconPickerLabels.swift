/// Chrome copy for ``IconPickerView``. Pass your own localized strings.
public struct IconPickerLabels: Equatable, Sendable {
    public var color: String
    public var icon: String
    public var emojis: String
    public var symbols: String
    public var search: String
    public var customColor: String
    public var suggestions: String

    public init(
        color: String = "Color",
        icon: String = "Icon",
        emojis: String = "Emojis",
        symbols: String = "Symbols",
        search: String = "Search Icons",
        customColor: String = "Custom",
        suggestions: String = "Suggestions")
    {
        self.color = color
        self.icon = icon
        self.emojis = emojis
        self.symbols = symbols
        self.search = search
        self.customColor = customColor
        self.suggestions = suggestions
    }

    public static let english = IconPickerLabels()
}
