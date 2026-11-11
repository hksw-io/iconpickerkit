/// Every string the picker shows or speaks. The kit ships none of its own, so pass your
/// app's localized strings.
///
/// Icon names and search keywords are the exception: the catalog's built-in English
/// metadata applies unless `iconNames` and `iconKeywords` override it. Both are keyed by
/// icon value, so changing language never changes a saved selection.
public struct IconPickerLabels: Sendable {
    /// Heading of the color swatches.
    public var color: String
    /// Heading of the row's icon button, and what VoiceOver calls that button.
    public var icon: String
    /// Prompt in the search field.
    public var search: String
    /// What VoiceOver calls the search field's clear button.
    public var clear: String
    /// Shown when the catalog has no groups.
    public var noIcons: String
    /// Heading of each group, `.suggestions` included.
    public var groupTitle: @Sendable (IconGroup) -> String
    /// A swatch's tooltip, and what VoiceOver calls it.
    public var colorName: @Sendable (IconPickerColor) -> String
    public var iconNames: [String: String]
    public var iconKeywords: [String: [String]]

    public init(
        color: String,
        icon: String,
        search: String,
        clear: String,
        noIcons: String,
        groupTitle: @escaping @Sendable (IconGroup) -> String,
        colorName: @escaping @Sendable (IconPickerColor) -> String,
        iconNames: [String: String] = [:],
        iconKeywords: [String: [String]] = [:])
    {
        self.color = color
        self.icon = icon
        self.search = search
        self.clear = clear
        self.noIcons = noIcons
        self.groupTitle = groupTitle
        self.colorName = colorName
        self.iconNames = iconNames
        self.iconKeywords = iconKeywords
    }

    func localized(_ item: IconItem) -> IconItem {
        IconItem(
            value: item.value,
            name: self.iconNames[item.value] ?? item.name,
            keywords: item.keywords + (self.iconKeywords[item.value] ?? []))
    }
}
