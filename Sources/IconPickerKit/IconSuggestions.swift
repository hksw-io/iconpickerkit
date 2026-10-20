import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// The actual inputs to a picker request, including replacement tasks and ready results.
struct IconSuggestionRequest: Equatable {
    let hint: String?
    let task: Task<IconSuggestions, Never>?
    let ready: IconSuggestions

    /// Whether the result arrives later, so the picker reserves the Suggestions row meanwhile.
    /// A blank hint never produces icons, so it reserves nothing.
    var loads: Bool {
        self.task != nil || !(self.hint ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func value(produce: @Sendable (String) async throws -> [String]) async -> IconSuggestions? {
        guard !Task.isCancelled else { return nil }
        let result: IconSuggestions
        if let task {
            result = await task.value
        } else if let hint {
            result = await IconSuggestions.load(hint: hint, produce: produce)
        } else {
            result = self.ready
        }
        return Task.isCancelled ? nil : result
    }
}

/// What the Suggestions row holds while it has no icons. Every state is one row tall,
/// so loading, filling in, and an empty result never move the catalog below.
enum IconSuggestionSlot: Equatable {
    case none
    case loading
    case noResults

    /// How long the opening transition hides a removed row. A later empty result keeps it instead.
    static let settle: Duration = .milliseconds(250)

    /// Placeholders while loading. The on-device model returns at most eight icons.
    static let placeholderCount = 8

    /// Whether the Suggestions row is on screen.
    func showsRow(hasItems: Bool) -> Bool {
        hasItems || self != .none
    }

    static func after(_ loaded: IconSuggestions, loads: Bool, waited: Duration) -> Self {
        loaded.isEmpty && loads && waited >= self.settle ? .noResults : .none
    }
}

/// Icons produced for a consumer hint. Empty means the Suggestions group has no icons.
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

    /// Starts `load(hint:produce:)` immediately so the result can be ready before the picker appears.
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

extension [IconItem] {
    /// The first `count` items, with `selected` swapped into the last slot when it would be cut off.
    func prefix(_ count: Int, keeping selected: String) -> [IconItem] {
        var shown = Array(self.prefix(count))
        if !shown.isEmpty, let item = self.dropFirst(count).first(where: { $0.value == selected }) {
            shown[shown.count - 1] = item
        }
        return shown
    }
}

extension String {
    var isSingleEmoji: Bool {
        guard self.count == 1, let first = self.first else { return false }
        return String(first).isEmoji
    }
}
