import SwiftUI

/// A compact color + icon control for forms and edit sheets.
///
/// Color swatches stay inline. The mixed emoji and SF Symbol catalog opens in
/// one popover.
public struct IconPickerRow: View {
    @Binding private var icon: String
    @Binding private var color: IconPickerColor
    private let colors: [IconPickerColor]
    let symbols: [String]
    let allowsCustomColor: Bool
    private let labels: IconPickerLabels

    @State private var showingCatalog = false
    @State private var query = ""
    @State private var debounce = SearchDebounce()
    @State private var origin = ContinuousClock.now

    @ScaledMetric(relativeTo: .title3) private var cellFont: CGFloat = 18

    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        symbols: [String] = SymbolCatalog.ids,
        allowsCustomColor: Bool = false,
        labels: IconPickerLabels = .english)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.symbols = symbols
        self.allowsCustomColor = allowsCustomColor
        self.labels = labels
    }

    public var body: some View {
        HStack(alignment: .center, spacing: IconPickerLayout.stackSpacing) {
            self.iconButton
            IconColorStrip(
                color: self.$color,
                colors: self.colors,
                allowsCustomColor: self.allowsCustomColor,
                customLabel: self.labels.customColor,
                swatchSize: IconPickerLayout.rowSwatchSize,
                contentInset: 0)
        }
    }

    private var iconButton: some View {
        Button {
            self.showingCatalog = true
        } label: {
            Group {
                if self.icon.isEmoji {
                    Text(verbatim: self.icon)
                        .font(.system(size: 20))
                } else {
                    Image(systemName: self.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(self.color.color)
                }
            }
            .frame(
                width: IconPickerLayout.rowIconButtonSize,
                height: IconPickerLayout.rowIconButtonSize)
            .background(self.color.color.opacity(0.15))
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(Color.accentColor, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
        .iconPickerHover()
        .help(self.labels.icon)
        .accessibilityLabel(self.labels.icon)
        .popover(isPresented: self.$showingCatalog) {
            self.catalogPopover
        }
    }

    private var catalogPopover: some View {
        VStack(spacing: IconPickerLayout.stackSpacing) {
            IconPickerSearchField(
                text: self.$query,
                debounce: self.$debounce,
                origin: self.origin,
                prompt: self.labels.search,
                autofocus: true)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: IconPickerLayout.stackSpacing) {
                    ForEach(IconPickerRowCatalog.sections(query: self.debounce.applied, symbols: self.symbols))
                    { section in
                        self.section(section)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 320, height: 280)
        #if os(macOS)
        .onExitCommand { self.showingCatalog = false }
        #endif
        .background {
            Button {
                self.showingCatalog = false
            } label: {
                EmptyView()
            }
            .keyboardShortcut(.cancelAction)
            .opacity(0)
            .accessibilityHidden(true)
        }
    }

    private func section(_ section: IconSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 36), spacing: 4)], spacing: 4) {
                ForEach(section.items) { item in
                    self.cell(item)
                }
            }
        }
    }

    private func cell(_ item: IconItem) -> some View {
        let isSelected = self.icon == item.value
        return Button {
            self.icon = item.value
            self.showingCatalog = false
        } label: {
            Group {
                if item.value.isEmoji {
                    Text(verbatim: item.value)
                        .font(.system(size: self.cellFont))
                } else {
                    Image(systemName: item.value)
                        .font(.system(size: self.cellFont * 0.8))
                        .foregroundStyle(isSelected ? self.color.color : .secondary)
                }
            }
            .frame(width: 32, height: 32)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(self.color.color.opacity(0.15))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

enum IconPickerRowCatalog {
    static func sections(query: String, symbols: [String]) -> [IconSection] {
        IconCatalog.search(query, symbols: symbols)
    }
}
