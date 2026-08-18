/// Chrome copy for ``IconPickerView``. Pass your own localized strings.
public struct IconPickerLabels: Equatable, Sendable {
    public var color: String
    public var icon: String
    public var emojis: String
    public var symbols: String
    public var search: String

    public init(
        color: String = "Color",
        icon: String = "Icon",
        emojis: String = "Emojis",
        symbols: String = "Symbols",
        search: String = "Search Icons")
    {
        self.color = color
        self.icon = icon
        self.emojis = emojis
        self.symbols = symbols
        self.search = search
    }

    public static let english = IconPickerLabels()
}
