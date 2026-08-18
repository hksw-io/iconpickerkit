import SwiftUI

/// A named swatch. Use a built-in preset or make your own.
public struct IconPickerColor: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let color: Color

    public init(id: String, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }

    public static let red = IconPickerColor(id: "red", name: "Red", color: .red)
    public static let orange = IconPickerColor(id: "orange", name: "Orange", color: .orange)
    public static let yellow = IconPickerColor(id: "yellow", name: "Yellow", color: .yellow)
    public static let green = IconPickerColor(id: "green", name: "Green", color: .green)
    public static let mint = IconPickerColor(id: "mint", name: "Mint", color: .mint)
    public static let teal = IconPickerColor(id: "teal", name: "Teal", color: .teal)
    public static let cyan = IconPickerColor(id: "cyan", name: "Cyan", color: .cyan)
    public static let blue = IconPickerColor(id: "blue", name: "Blue", color: .blue)
    public static let indigo = IconPickerColor(id: "indigo", name: "Indigo", color: .indigo)
    public static let purple = IconPickerColor(id: "purple", name: "Purple", color: .purple)
    public static let pink = IconPickerColor(id: "pink", name: "Pink", color: .pink)
    public static let brown = IconPickerColor(id: "brown", name: "Brown", color: .brown)
    public static let primary = IconPickerColor(id: "primary", name: "Label", color: .primary)

    public static let all: [IconPickerColor] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown,
        .primary,
    ]
}
