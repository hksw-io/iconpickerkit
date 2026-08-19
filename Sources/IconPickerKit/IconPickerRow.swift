import SwiftUI

/// A compact color + icon control for forms and edit sheets.
///
/// Color swatches stay inline. Emoji and SF Symbol grids open in popovers.
public struct IconPickerRow: View {
    @Binding private var icon: String
    @Binding private var color: IconPickerColor
    private let colors: [IconPickerColor]
    let symbols: [String]
    let allowsCustomColor: Bool
    private let labels: IconPickerLabels

    @State private var showingEmojis = false
    @State private var showingSymbols = false
    @State private var query = ""
    @State private var debounce = SearchDebounce()
    @State private var origin = ContinuousClock.now

    @ScaledMetric(relativeTo: .title3) private var gridEmojiSize: CGFloat = 22
    @ScaledMetric(relativeTo: .body) private var gridSymbolSize: CGFloat = 18

    private var isEmojiSelected: Bool {
        self.icon.isEmoji
    }

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
        VStack(alignment: .leading, spacing: 16) {
            self.colorSection
            self.iconSection
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(self.labels.color)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            IconColorStrip(
                color: self.$color,
                colors: self.colors,
                allowsCustomColor: self.allowsCustomColor,
                customLabel: self.labels.customColor,
                swatchSize: 24,
                contentInset: 0)
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(self.labels.icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 8) {
                self.emojiButton
                self.symbolButton
            }
        }
    }

    private var emojiButton: some View {
        Button {
            self.showingEmojis = true
        } label: {
            Group {
                if self.isEmojiSelected {
                    Text(verbatim: self.icon)
                } else {
                    Text(verbatim: "😀")
                }
            }
            .font(.system(size: 20))
            .frame(width: 44, height: 44)
            .background(self.color.color.opacity(0.15))
            .clipShape(Circle())
            .overlay {
                if self.isEmojiSelected {
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(self.labels.emojis)
        .accessibilityAddTraits(self.isEmojiSelected ? .isSelected : [])
        .popover(isPresented: self.$showingEmojis) {
            self.emojiPopover
        }
    }

    private var symbolButton: some View {
        Button {
            self.showingSymbols = true
        } label: {
            Image(systemName: self.isEmojiSelected ? "list.bullet" : self.icon)
                .font(.system(size: 16))
                .foregroundStyle(self.color.color)
                .frame(width: 44, height: 44)
                .background(self.color.color.opacity(0.15))
                .clipShape(Circle())
                .overlay {
                    if !self.isEmojiSelected {
                        Circle()
                            .strokeBorder(Color.accentColor, lineWidth: 2)
                    }
                }
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(self.labels.symbols)
        .accessibilityAddTraits(self.isEmojiSelected ? [] : .isSelected)
        .popover(isPresented: self.$showingSymbols) {
            self.symbolPopover
        }
    }

    private var emojiPopover: some View {
        VStack(spacing: IconPickerLayout.stackSpacing) {
            IconPickerSearchField(
                text: self.$query,
                debounce: self.$debounce,
                origin: self.origin,
                prompt: self.labels.search)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 36), spacing: 4)], spacing: 4) {
                    ForEach(EmojiCatalog.search(self.debounce.applied)) { item in
                        self.emojiCell(item)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 320, height: 240)
    }

    private func emojiCell(_ item: EmojiItem) -> some View {
        let isSelected = self.icon == item.emoji
        return Button {
            self.icon = item.emoji
            self.showingEmojis = false
        } label: {
            Text(verbatim: item.emoji)
                .font(.system(size: self.gridEmojiSize))
                .frame(width: 32, height: 32)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor.opacity(0.2))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var symbolPopover: some View {
        VStack(spacing: IconPickerLayout.stackSpacing) {
            IconPickerSearchField(
                text: self.$query,
                debounce: self.$debounce,
                origin: self.origin,
                prompt: self.labels.search)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 6)], spacing: 6) {
                    ForEach(SymbolCatalog.search(self.debounce.applied, in: self.symbols), id: \.self) { symbol in
                        self.symbolCell(symbol)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 320, height: 280)
    }

    private func symbolCell(_ symbol: String) -> some View {
        let isSelected = self.icon == symbol
        return Button {
            self.icon = symbol
            self.showingSymbols = false
        } label: {
            Image(systemName: symbol)
                .font(.system(size: self.gridSymbolSize))
                .foregroundStyle(isSelected ? self.color.color : .secondary)
                .frame(width: 36, height: 36)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(self.color.color.opacity(0.15))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symbol)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
