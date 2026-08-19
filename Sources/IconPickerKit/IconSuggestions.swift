import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Icons produced for a consumer hint. Empty means the extra group is omitted.
public struct IconSuggestions: Sendable, Equatable {
    public let items: [IconItem]

    public init(items: [IconItem] = []) {
        self.items = items
    }

    public static let empty = IconSuggestions()

    public var isEmpty: Bool { self.items.isEmpty }

    /// Loads suggestions for `hint`. An empty hint does not call `produce`.
    public static func load(
        hint: String,
        produce: @Sendable (String) async throws -> [String]
    ) async -> IconSuggestions {
        let trimmed = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }
        do {
            return IconSuggestions(items: Self.items(from: try await produce(trimmed)))
        } catch {
            return .empty
        }
    }

    /// Loads suggestions for `hint` with the on-device Foundation Model.
    public static func load(hint: String) async -> IconSuggestions {
        await self.load(hint: hint, produce: self.foundationModels)
    }

    /// Starts `load(hint:)` immediately so the result can be ready before the picker appears.
    ///
    /// Call this from the screen that presents the picker — typically in a
    /// `.task(id: hint)` on the edit form — and pass the task into
    /// ``IconPickerView``. Do not start it from the picker's own appear path.
    public static func preload(
        hint: String,
        produce: @escaping @Sendable (String) async throws -> [String]
    ) -> Task<IconSuggestions, Never> {
        Task { await self.load(hint: hint, produce: produce) }
    }

    /// Starts `load(hint:)` with the on-device Foundation Model.
    public static func preload(hint: String) -> Task<IconSuggestions, Never> {
        self.preload(hint: hint, produce: self.foundationModels)
    }

    static func items(from raw: [String]) -> [IconItem] {
        var seen = Set<String>()
        var items: [IconItem] = []
        for token in raw {
            let value = token.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty, seen.insert(value).inserted else { continue }
            if value.isSingleEmoji {
                items.append(IconItem(value: value, name: value))
            } else if Self.isKnownSymbol(value) {
                items.append(
                    IconItem(
                        value: value,
                        name: value.replacingOccurrences(of: ".", with: " "),
                        keywords: value.split(separator: ".").map(String.init)))
            }
        }
        return items
    }

    static func foundationModels(_ hint: String) async throws -> [String] {
        #if canImport(FoundationModels)
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
        #else
        return []
        #endif
    }

    private static func isKnownSymbol(_ name: String) -> Bool {
        #if canImport(AppKit)
        NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
        #elseif canImport(UIKit)
        UIImage(systemName: name) != nil
        #else
        SymbolCatalog.ids.contains(name)
        #endif
    }
}

extension String {
    var isSingleEmoji: Bool {
        guard self.count == 1, let first = self.first else { return false }
        return String(first).isEmoji
    }
}

#if canImport(FoundationModels)
@Generable
nonisolated struct IconSuggestionDraft {
    @Guide(description: "At most eight emoji characters or SF Symbol names")
    var icons: [String]
}
#endif
