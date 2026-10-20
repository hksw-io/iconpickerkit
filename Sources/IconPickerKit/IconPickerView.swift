import SwiftUI

/// A picker for a tint color plus an emoji or SF Symbol.
///
/// Bind `icon` to an emoji character or an SF Symbol name. Bind `color` to a
/// palette swatch. The consumer owns both values and presents the view
/// however it wants — typically in a sheet.
public struct IconPickerView: View {
    @Binding private var icon: String
    @Binding private var color: IconPickerColor
    private let colors: [IconPickerColor]
    let symbols: [String]
    let catalog: IconCatalogPreset
    let allowsCustomColor: Bool
    let hint: String?
    let produce: @Sendable (String) async throws -> [String]
    let suggestionTask: Task<IconSuggestions, Never>?
    let readySuggestions: IconSuggestions
    private let labels: IconPickerLabels

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @State private var debounce = SearchDebounce()
    @State private var origin = ContinuousClock.now
    @State private var suggestions = IconSuggestions.empty
    @State private var userHasScrolled = false
    @State private var catalogIsAtTop = true
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var selectionVisibility = IconPickerSelectionVisibility()

    @ScaledMetric(relativeTo: .title3) private var cellFont: CGFloat = 22
    @ScaledMetric(relativeTo: .title3) private var cellSize: CGFloat = 44

    /// Creates a picker bound to the consumer's icon string and tint color.
    ///
    /// Pass `colors` to replace the built-in palette with your own swatches,
    /// including brand colors. Pass `symbols` to replace the built-in SF Symbol
    /// catalog. Pass `catalog` to choose groups, order, and per-group caps.
    /// Pass `allowsCustomColor` to append a system color picker on the far right.
    /// Pass `suggestions` to reuse work started with
    /// ``IconSuggestions/preload(hint:produce:)`` before the picker appears —
    /// that is the path that can have the group ready on first layout.
    /// Appear-scroll does not wait for it. On-device model suggestions live in
    /// the separate `IconPickerKitIntelligence` product.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        allowsCustomColor: Bool = false,
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
            hint: nil,
            produce: { _ in [] },
            suggestions: suggestions,
            labels: labels)
    }

    /// Asks `produce` for suggestions for `hint` after appear, unless `suggestions` is supplied.
    package init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor],
        symbols: [String],
        catalog: IconCatalogPreset,
        allowsCustomColor: Bool,
        hint: String?,
        produce: @escaping @Sendable (String) async throws -> [String],
        suggestions: Task<IconSuggestions, Never>?,
        labels: IconPickerLabels)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.symbols = symbols
        self.catalog = catalog
        self.allowsCustomColor = allowsCustomColor
        self.hint = hint
        self.produce = produce
        self.suggestionTask = suggestions
        self.readySuggestions = .empty
        self.labels = labels
        self._suggestions = State(initialValue: .empty)
    }

    /// Creates a picker whose Suggestions group is already populated.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        allowsCustomColor: Bool = false,
        suggestions: IconSuggestions,
        labels: IconPickerLabels = .english)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.symbols = symbols
        self.catalog = catalog
        self.allowsCustomColor = allowsCustomColor
        self.hint = nil
        self.produce = { _ in [] }
        self.suggestionTask = nil
        self.readySuggestions = suggestions
        self.labels = labels
        self._suggestions = State(initialValue: suggestions)
    }

    public var body: some View {
        let request = IconSuggestionRequest(hint: self.hint, task: self.suggestionTask, ready: self.readySuggestions)
        VStack(spacing: IconPickerLayout.sectionSpacing) {
            if IconKind.offersColorChrome(for: self.icon) {
                self.colorSection
                    .clipped()
                    .transition(IconPickerExpand.vertical(reduceMotion: self.reduceMotion))
            }
            self.search
            self.catalogScroll
        }
        .animation(
            IconPickerScrollPolicy.colorChromeAnimation(reduceMotion: self.reduceMotion),
            value: IconKind.offersColorChrome(for: self.icon))
        .padding(.top)
        .background(.background)
        .task {
            await self.scrollToSelectionIfNeeded()
        }
        .task(id: request) {
            await self.applySuggestions(request)
        }
    }

    private var catalogScroll: some View {
        ScrollView {
            self.catalogList
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollPosition($scrollPosition)
        .onScrollPhaseChange { _, phase in
            if phase == .interacting {
                self.userHasScrolled = true
            }
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            IconPickerScrollPolicy.catalogIsAtTop(
                offsetY: geometry.contentOffset.y,
                insetTop: geometry.contentInsets.top)
        } action: { _, atTop in
            self.catalogIsAtTop = atTop
        }
    }

    private func applySuggestions(_ request: IconSuggestionRequest) async {
        guard let loaded = await request.value(produce: self.produce), loaded != self.suggestions else { return }
        withAnimation(
            IconPickerScrollPolicy.suggestionAppearAnimation(
                reduceMotion: self.reduceMotion,
                catalogIsAtTop: self.catalogIsAtTop)
        ) {
            self.suggestions = loaded
        }
    }

    private func scrollToSelectionIfNeeded() async {
        try? await Task.sleep(for: IconPickerScrollPolicy.layoutSettle)
        guard IconPickerScrollPolicy.shouldScrollToSelection(
            userHasScrolled: self.userHasScrolled,
            selectionIsVisible: self.selectionVisibility.isOnScreen)
        else {
            return
        }
        let section = IconCatalog.section(
            containing: self.icon,
            symbols: self.symbols,
            catalog: self.catalog,
            suggestions: self.suggestions.items,
            labels: self.labels)
        // The icon's id sits inside a lazy grid that has no layout until its section is on
        // screen, so bring the section in first and target the icon once it has laid out.
        if let section {
            self.scrollPosition.scrollTo(id: section.id, anchor: .center)
            try? await Task.sleep(for: IconPickerScrollPolicy.layoutSettle)
        }
        withAnimation(IconPickerScrollPolicy.scrollAnimation(reduceMotion: self.reduceMotion)) {
            self.scrollPosition.scrollTo(id: self.icon, anchor: .center)
        }
    }

    private var search: some View {
        IconPickerSearchField(
            text: self.$query,
            debounce: self.$debounce,
            origin: self.origin,
            prompt: self.labels.search,
            clearLabel: self.labels.clear)
            .padding(.horizontal, IconPickerLayout.horizontalInset)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: IconPickerLayout.stackSpacing) {
            Text(self.labels.color)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, IconPickerLayout.horizontalInset)
                .accessibilityAddTraits(.isHeader)
            IconColorStrip(
                color: self.$color,
                colors: self.colors,
                allowsCustomColor: self.allowsCustomColor,
                customLabel: self.labels.customColor,
                swatchSize: IconPickerLayout.swatchSize,
                colorNames: self.labels.colorNames)
        }
    }

    private var catalogList: some View {
        let sections = IconCatalog.search(
            self.debounce.applied,
            symbols: self.symbols,
            catalog: self.catalog,
            suggestions: self.suggestions.items,
            labels: self.labels)
        let suggestion = sections.first { $0.group == .suggestions }
        return LazyVStack(
            alignment: .leading,
            spacing: IconPickerLayout.sectionSpacing,
            pinnedViews: .sectionHeaders)
        {
            if sections.isEmpty {
                IconPickerEmptyState(query: self.debounce.applied, noIcons: self.labels.noIcons)
            }
            if let suggestion {
                Section {
                    self.sectionGrid(suggestion)
                } header: {
                    self.sectionHeader(suggestion)
                }
                .id(suggestion.id)
                .clipped()
                .transition(IconPickerExpand.vertical(reduceMotion: self.reduceMotion))
            }
            ForEach(sections.filter { $0.group != .suggestions }) { section in
                Section {
                    self.sectionGrid(section)
                } header: {
                    self.sectionHeader(section)
                }
                .id(section.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .scrollTargetLayout()
    }

    private func sectionHeader(_ section: IconSection) -> some View {
        Text(section.title)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, IconPickerLayout.catalogInset)
            .padding(.vertical, 6)
            .background(.background)
            .accessibilityAddTraits(.isHeader)
    }

    private func sectionGrid(_ section: IconSection) -> some View {
        LazyVGrid(columns: self.columns, spacing: IconPickerLayout.stackSpacing) {
            ForEach(section.items) { item in
                self.iconButton(item)
                    .id(item.value)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, IconPickerLayout.catalogInset)
    }

    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: self.cellSize, maximum: self.cellSize * 1.4),
                spacing: IconPickerLayout.stackSpacing),
        ]
    }

    private func iconButton(_ item: IconItem) -> some View {
        let isSelected = self.icon == item.value
        return Button {
            self.icon = item.value
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? self.color.color.opacity(0.15) : Color.clear)
                    .frame(width: self.cellSize, height: self.cellSize)
                if item.value.isEmoji {
                    Text(verbatim: item.value)
                        .font(.system(size: self.cellFont))
                } else {
                    Image(systemName: item.value)
                        .font(.system(size: self.cellFont))
                        .foregroundStyle(isSelected ? self.color.color : .secondary)
                }
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(self.color.color, lineWidth: 2)
                        .frame(width: self.cellSize, height: self.cellSize)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .onScrollVisibilityChange { visible in
            guard isSelected else { return }
            self.selectionVisibility.isOnScreen = visible
        }
    }
}

@MainActor
private final class IconPickerSelectionVisibility {
    var isOnScreen = false
}
