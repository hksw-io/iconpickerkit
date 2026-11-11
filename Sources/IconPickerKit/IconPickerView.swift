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
    let catalog: IconCatalogPreset
    let hint: String?
    let produce: @Sendable (String) async throws -> [String]
    let readySuggestions: IconSuggestions
    private let labels: IconPickerLabels

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    /// The icon the picker opened with. The catalog keeps a cell for it even when it lists no
    /// such icon; tracking the live selection instead would shift the grid under each tap.
    @State private var openedWith: String
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
    /// including brand colors. Pass `catalog` to choose the groups and their order.
    /// Pass `suggestions` to show a Suggestions group you loaded yourself, for
    /// example with ``IconSuggestions/load(hint:produce:)``. On-device model
    /// suggestions live in the separate `IconPickerKitIntelligence` product.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        catalog: IconCatalogPreset = .all,
        suggestions: IconSuggestions = .empty,
        labels: IconPickerLabels)
    {
        self.init(
            icon: icon,
            color: color,
            colors: colors,
            catalog: catalog,
            hint: nil,
            produce: { _ in [] },
            suggestions: suggestions,
            labels: labels)
    }

    /// Asks `produce` for suggestions for `hint` after appear. Without a hint it shows `suggestions`.
    package init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor],
        catalog: IconCatalogPreset,
        hint: String?,
        produce: @escaping @Sendable (String) async throws -> [String],
        suggestions: IconSuggestions,
        labels: IconPickerLabels)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.catalog = catalog
        self.hint = hint
        self.produce = produce
        self.readySuggestions = suggestions
        self.labels = labels
        self._suggestions = State(initialValue: suggestions)
        self._openedWith = State(initialValue: icon.wrappedValue)
    }

    public var body: some View {
        let request = IconSuggestionRequest(hint: self.hint, ready: self.readySuggestions)
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
                swatchSize: IconPickerLayout.swatchSize,
                colorName: self.labels.colorName)
        }
    }

    private var catalogList: some View {
        let sections = IconCatalog.search(
            self.query,
            catalog: self.catalog,
            suggestions: self.suggestions.items,
            labels: self.labels,
            selected: self.openedWith)
        let suggestion = sections.first { $0.group == .suggestions }
        return LazyVStack(
            alignment: .leading,
            spacing: IconPickerLayout.sectionSpacing,
            pinnedViews: .sectionHeaders)
        {
            if sections.isEmpty {
                IconPickerEmptyState(query: self.query, noIcons: self.labels.noIcons)
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
        return IconPickerCell(
            item: item,
            isSelected: isSelected,
            tint: self.color.color,
            size: self.cellSize,
            font: self.cellFont)
        {
            self.icon = item.value
        }
        .onScrollVisibilityChange { visible in
            guard isSelected else { return }
            self.selectionVisibility.isOnScreen = visible
        }
    }
}

/// One catalog cell in the full picker. The whole cell is the tap target, not only its glyph.
struct IconPickerCell: View {
    let item: IconItem
    let isSelected: Bool
    let tint: Color
    let size: CGFloat
    let font: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(self.isSelected ? self.tint.opacity(0.15) : Color.clear)
                if self.item.value.isEmoji {
                    Text(verbatim: self.item.value)
                        .font(.system(size: self.font))
                } else {
                    Image(systemName: self.item.value)
                        .font(.system(size: self.font))
                        .foregroundStyle(self.isSelected ? self.tint : .secondary)
                }
                if self.isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(self.tint, lineWidth: 2)
                }
            }
            .frame(width: self.size, height: self.size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(self.item.name)
        .accessibilityAddTraits(self.isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

@MainActor
private final class IconPickerSelectionVisibility {
    var isOnScreen = false
}
