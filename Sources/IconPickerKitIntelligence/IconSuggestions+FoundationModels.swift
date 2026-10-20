import FoundationModels
import IconPickerKit
import SwiftUI

extension IconSuggestions {
    /// Loads suggestions for `hint` with the on-device Foundation Model.
    public static func load(hint: String) async -> IconSuggestions {
        await self.load(hint: hint, produce: self.foundationModels)
    }

    /// Starts `load(hint:)` with the on-device Foundation Model.
    ///
    /// Call this from the screen that presents the picker — typically in a
    /// `.task(id: hint)` on the edit form — and pass the task into
    /// ``IconPickerKit/IconPickerView``. Do not start it from the picker's own appear path.
    public static func preload(hint: String) -> Task<IconSuggestions, Never> {
        self.preload(hint: hint, produce: self.foundationModels)
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
    /// A `nil` hint asks for nothing. Pass `suggestions` to reuse work started
    /// with ``IconSuggestions/preload(hint:)`` before the picker
    /// appears; the task wins over the hint. Appear-scroll does not wait for either.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        allowsCustomColor: Bool = false,
        hint: String?,
        suggestions: Task<IconSuggestions, Never>? = nil,
        labels: IconPickerLabels = .english)
    {
        self.init(
            icon: icon,
            color: color,
            colors: colors,
            symbols: symbols,
            catalog: catalog,
            allowsCustomColor: allowsCustomColor,
            hint: hint,
            produce: IconSuggestions.foundationModels,
            suggestions: suggestions,
            labels: labels)
    }
}

@Generable
nonisolated struct IconSuggestionDraft {
    @Guide(description: "At most eight emoji characters or SF Symbol names")
    var icons: [String]
}
