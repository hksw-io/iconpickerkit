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
    private let labels: IconPickerLabels

    @State private var query = ""
    @State private var debounce = SearchDebounce()
    @State private var origin = ContinuousClock.now

    @ScaledMetric(relativeTo: .title3) private var cellFont: CGFloat = 22
    @ScaledMetric(relativeTo: .title3) private var cellSize: CGFloat = 44

    /// Creates a picker bound to the consumer's icon string and tint color.
    ///
    /// Pass `colors` to replace the built-in palette with your own swatches,
    /// including brand colors. Pass `symbols` to replace the built-in SF Symbol
    /// catalog. Pass `catalog` to choose groups, order, and per-group caps.
    /// Pass `allowsCustomColor` to append a system color picker on the far right.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        symbols: [String] = SymbolCatalog.ids,
        catalog: IconCatalogPreset = .all,
        allowsCustomColor: Bool = false,
        labels: IconPickerLabels = .english)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.symbols = symbols
        self.catalog = catalog
        self.allowsCustomColor = allowsCustomColor
        self.labels = labels
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: IconPickerLayout.sectionSpacing) {
                    self.colorSection
                    self.search
                    self.catalogList
                }
                .padding(.vertical)
            }
            .task {
                try? await Task.sleep(for: .milliseconds(16))
                if let section = IconCatalog.section(
                    containing: self.icon,
                    symbols: self.symbols,
                    catalog: self.catalog)
                {
                    proxy.scrollTo(section.id, anchor: .center)
                }
                proxy.scrollTo(self.icon, anchor: .center)
            }
        }
    }

    private var search: some View {
        IconPickerSearchField(
            text: self.$query,
            debounce: self.$debounce,
            origin: self.origin,
            prompt: self.labels.search)
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
                swatchSize: IconPickerLayout.swatchSize)
        }
    }

    private var catalogList: some View {
        LazyVStack(alignment: .leading, spacing: IconPickerLayout.sectionSpacing) {
            ForEach(
                IconCatalog.search(
                    self.debounce.applied,
                    symbols: self.symbols,
                    catalog: self.catalog))
            { section in
                self.section(section)
                    .id(section.id)
            }
        }
        .padding(.horizontal, IconPickerLayout.horizontalInset)
    }

    private func section(_ section: IconSection) -> some View {
        VStack(alignment: .leading, spacing: IconPickerLayout.stackSpacing) {
            Text(section.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
            LazyVGrid(columns: self.columns, spacing: IconPickerLayout.stackSpacing) {
                ForEach(section.items) { item in
                    self.iconButton(item)
                        .id(item.value)
                }
            }
        }
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
    }
}
