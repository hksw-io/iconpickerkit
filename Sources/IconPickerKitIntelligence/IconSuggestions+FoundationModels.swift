import FoundationModels
import IconPickerKit
import SwiftUI

extension IconSuggestions {
    /// Loads suggestions for `hint` with the on-device Foundation Model.
    public static func load(hint: String) async -> IconSuggestions {
        await self.load(hint: hint, produce: self.foundationModels)
    }

    static func foundationModels(_ hint: String) async throws -> [String] {
        guard case .available = SystemLanguageModel.default.availability else {
            return []
        }
        let session = LanguageModelSession(
            instructions: """
                Suggest icons for a named item.
                Return at most 8 values.
                Each value is one emoji (including country flags) or one SF Symbol name \
                such as folder or flag.fill.
                No sentences, no punctuation, no explanations.
                """)
        let response = try await session.respond(
            to: "Icons for: \(hint)",
            generating: IconSuggestionDraft.self)
        return response.content.icons
    }
}

extension IconPickerView {
    /// Creates a picker that asks the on-device Foundation Model for icons
    /// matching `hint` (a deck name, title, …) after appear.
    ///
    /// A `nil` hint asks for nothing. Appear-scroll does not wait for the model.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        catalog: IconCatalogPreset = .all,
        hint: String?,
        labels: IconPickerLabels,
        image: @escaping (IconItem) -> Image? = { _ in nil })
    {
        self.init(
            icon: icon,
            color: color,
            colors: colors,
            catalog: catalog,
            hint: hint,
            produce: IconSuggestions.foundationModels,
            suggestions: .empty,
            labels: labels,
            image: image)
    }
}

@Generable
nonisolated struct IconSuggestionDraft {
    @Guide(description: "Emoji characters or SF Symbol names", .maximumCount(8))
    var icons: [String]
}
