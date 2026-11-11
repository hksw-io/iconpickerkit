import SwiftUI

/// A swatch. Use a built-in preset or make your own; ``IconPickerLabels/colorName`` names it.
public struct IconPickerColor: Identifiable, Hashable, Sendable {
    public let id: String
    public let color: Color

    public init(id: String, color: Color) {
        self.id = id
        self.color = color
    }

    public static let red = IconPickerColor(id: "red", color: .red)
    public static let orange = IconPickerColor(id: "orange", color: .orange)
    public static let yellow = IconPickerColor(id: "yellow", color: .yellow)
    public static let green = IconPickerColor(id: "green", color: .green)
    public static let mint = IconPickerColor(id: "mint", color: .mint)
    public static let teal = IconPickerColor(id: "teal", color: .teal)
    public static let cyan = IconPickerColor(id: "cyan", color: .cyan)
    public static let blue = IconPickerColor(id: "blue", color: .blue)
    public static let indigo = IconPickerColor(id: "indigo", color: .indigo)
    public static let purple = IconPickerColor(id: "purple", color: .purple)
    public static let pink = IconPickerColor(id: "pink", color: .pink)
    public static let brown = IconPickerColor(id: "brown", color: .brown)
    public static let primary = IconPickerColor(id: "primary", color: .primary)

    public static let all: [IconPickerColor] = [
        .red, .orange, .yellow, .green, .mint, .blue, .indigo, .purple, .pink,
    ]
}
