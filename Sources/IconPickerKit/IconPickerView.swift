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
    private let labels: IconPickerLabels

    @State private var query = ""
    @State private var debounce = SearchDebounce()
    @State private var origin = ContinuousClock.now

    @ScaledMetric(relativeTo: .largeTitle) private var previewSize: CGFloat = 48
    @ScaledMetric(relativeTo: .title3) private var cellFont: CGFloat = 22
    @ScaledMetric(relativeTo: .title3) private var cellSize: CGFloat = 44

    /// Creates a picker bound to the consumer's icon string and tint color.
    ///
    /// Pass `colors` to replace the built-in palette with your own swatches,
    /// including brand colors. Pass `symbols` to replace the built-in SF Symbol
    /// catalog.
    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        symbols: [String] = SymbolCatalog.ids,
        labels: IconPickerLabels = .english)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.symbols = symbols
        self.labels = labels
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: IconPickerLayout.sectionSpacing) {
                self.search
                self.preview
                self.colorSection
                self.catalog
            }
            .padding(.vertical)
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

    private var preview: some View {
        Group {
            if self.icon.isEmoji {
                Text(verbatim: self.icon)
                    .font(.system(size: self.previewSize))
            } else {
                Image(systemName: self.icon)
                    .font(.system(size: self.previewSize))
                    .foregroundStyle(self.color.color)
            }
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(self.color.color.opacity(0.15)))
        .accessibilityHidden(true)
    }

    private var colorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: IconPickerLayout.stackSpacing) {
                ForEach(self.colors) { swatch in
                    self.colorSwatch(swatch)
                }
            }
        }
        .padding(.horizontal, IconPickerLayout.horizontalInset)
    }

    private func colorSwatch(_ swatch: IconPickerColor) -> some View {
        let isSelected = swatch == self.color
        return Button {
            self.color = swatch
        } label: {
            ZStack {
                Circle()
                    .fill(swatch.color)
                    .frame(
                        width: IconPickerLayout.swatchSize,
                        height: IconPickerLayout.swatchSize)
                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(
                            width: IconPickerLayout.swatchSize - 4,
                            height: IconPickerLayout.swatchSize - 4)
                }
            }
            .frame(width: IconPickerLayout.swatchSize, height: IconPickerLayout.swatchSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(swatch.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var catalog: some View {
        LazyVStack(alignment: .leading, spacing: IconPickerLayout.sectionSpacing) {
            ForEach(IconCatalog.search(self.debounce.applied, symbols: self.symbols)) { section in
                self.section(section)
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
