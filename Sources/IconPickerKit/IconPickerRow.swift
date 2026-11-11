import SwiftUI

/// A compact color + icon control for forms and edit sheets.
///
/// Color swatches stay inline. The mixed emoji and SF Symbol catalog opens in
/// one popover.
public struct IconPickerRow: View {
    @Binding private var icon: String
    @Binding private var color: IconPickerColor
    private let colors: [IconPickerColor]
    private let labels: IconPickerLabels

    @State private var showingCatalog = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(
        icon: Binding<String>,
        color: Binding<IconPickerColor>,
        colors: [IconPickerColor] = IconPickerColor.all,
        labels: IconPickerLabels)
    {
        self._icon = icon
        self._color = color
        self.colors = colors
        self.labels = labels
    }

    public var body: some View {
        let layout = self.dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: IconPickerLayout.stackSpacing))
            : AnyLayout(HStackLayout(alignment: .center, spacing: IconPickerLayout.stackSpacing))
        return layout {
            HStack(spacing: IconPickerLayout.stackSpacing) {
                Text(self.labels.icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize()
                    .accessibilityAddTraits(.isHeader)
                self.iconButton
            }
            if IconKind.offersColorChrome(for: self.icon) {
                HStack(alignment: .center, spacing: IconPickerLayout.stackSpacing) {
                    if !self.dynamicTypeSize.isAccessibilitySize {
                        Divider()
                            .frame(height: IconPickerLayout.rowIconButtonSize)
                    }
                    Text(self.labels.color)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                        .accessibilityAddTraits(.isHeader)
                    IconColorStrip(
                        color: self.$color,
                        colors: self.colors,
                        swatchSize: IconPickerLayout.rowSwatchSize,
                        colorName: self.labels.colorName,
                        contentInset: 0)
                }
                .clipped()
                .transition(IconPickerExpand.horizontal(reduceMotion: self.reduceMotion))
            }
        }
        .animation(
            IconPickerScrollPolicy.colorChromeAnimation(reduceMotion: self.reduceMotion),
            value: IconKind.offersColorChrome(for: self.icon))
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
        .padding(IconPickerHover.overflow(for: IconPickerLayout.rowIconButtonSize))
        .help(self.labels.icon)
        .accessibilityLabel(self.labels.icon)
        .accessibilityValue(self.labels.iconNames[self.icon] ?? self.icon.replacingOccurrences(of: ".", with: " "))
        .popover(isPresented: self.$showingCatalog) {
            IconPickerRowCatalog(
                icon: self.$icon,
                tint: self.color.color,
                labels: self.labels,
                isPresented: self.$showingCatalog)
        }
    }
}

/// The row's popover. It owns the search query, so each presentation starts with an empty search.
private struct IconPickerRowCatalog: View {
    @Binding var icon: String
    let tint: Color
    let labels: IconPickerLabels
    @Binding var isPresented: Bool

    @State private var query = ""
    @ScaledMetric(relativeTo: .title3) private var cellFont: CGFloat = 18
    @ScaledMetric(relativeTo: .title3) private var cellSize: CGFloat = IconPickerLayout.rowCellSize

    var body: some View {
        let sections = IconCatalog.search(self.query, labels: self.labels, selected: self.icon)
        VStack(spacing: IconPickerLayout.stackSpacing) {
            IconPickerSearchField(
                text: self.$query,
                prompt: self.labels.search,
                autofocus: IconPickerLayout.autofocusRowSearch,
                clearLabel: self.labels.clear)
            {
                if let pick = IconCatalog.submitPick(self.query, in: sections) {
                    self.icon = pick
                    self.isPresented = false
                }
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: IconPickerLayout.stackSpacing) {
                    if sections.isEmpty {
                        IconPickerEmptyState(query: self.query, noIcons: self.labels.noIcons)
                    }
                    ForEach(sections) { section in
                        self.section(section)
                    }
                }
            }
        }
        .padding(12)
        .frame(idealWidth: 320, idealHeight: 280)
        #if os(macOS)
        .frame(minWidth: 280, minHeight: 280)
        #endif
        #if os(macOS)
        .onExitCommand { self.isPresented = false }
        #endif
        .background {
            Button {
                self.isPresented = false
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
            LazyVGrid(columns: [GridItem(.adaptive(minimum: max(36, self.cellSize)), spacing: 4)], spacing: 4) {
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
            self.isPresented = false
        } label: {
            Group {
                if item.value.isEmoji {
                    Text(verbatim: item.value)
                        .font(.system(size: self.cellFont))
                } else {
                    Image(systemName: item.value)
                        .font(.system(size: self.cellFont * 0.8))
                        .foregroundStyle(isSelected ? self.tint : .secondary)
                }
            }
            .frame(width: self.cellSize, height: self.cellSize)
            .contentShape(Rectangle())
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(self.tint.opacity(0.15))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
