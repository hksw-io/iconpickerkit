import SwiftUI

/// A picker for a tint color plus an emoji or SF Symbol.
///
/// Bind `icon` to an emoji character or an SF Symbol name. Bind `color` to a
/// palette swatch. The consumer owns both values and presents the view
/// however it wants — typically in a sheet.
public struct IconPickerView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case emojis
        case symbols

        var id: String { self.rawValue }

        var title: String {
            switch self {
            case .emojis: "Emojis"
            case .symbols: "Symbols"
            }
        }
    }

    @Binding private var icon: String
    @Binding private var color: IconPickerColor

    @State private var mode: Mode
    @State private var query = ""

    @ScaledMetric(relativeTo: .largeTitle) private var previewSize: CGFloat = 48
    @ScaledMetric(relativeTo: .title3) private var cellFont: CGFloat = 22
    @ScaledMetric(relativeTo: .title3) private var cellSize: CGFloat = 44

    /// Creates a picker bound to the consumer's icon string and tint color.
    public init(icon: Binding<String>, color: Binding<IconPickerColor>) {
        self._icon = icon
        self._color = color
        self._mode = State(initialValue: icon.wrappedValue.isEmoji ? .emojis : .symbols)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                self.preview
                self.colorSection
                self.iconSection
            }
            .padding(.vertical)
        }
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
        .padding(.top, 8)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(IconPickerColor.allCases) { swatch in
                        self.colorSwatch(swatch)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func colorSwatch(_ swatch: IconPickerColor) -> some View {
        let isSelected = swatch == self.color
        return Button {
            self.color = swatch
        } label: {
            ZStack {
                Circle()
                    .fill(swatch.color)
                    .frame(width: 32, height: 32)
                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(swatch.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)

            Picker("Icon", selection: self.$mode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if self.mode == .emojis {
                TextField("Search", text: self.$query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .accessibilityLabel("Search")
                self.emojiGrid
            } else {
                self.symbolGrid
            }
        }
    }

    private var emojiGrid: some View {
        LazyVGrid(columns: self.columns, spacing: 12) {
            ForEach(EmojiCatalog.search(self.query)) { item in
                self.emojiButton(item)
            }
        }
        .padding(.horizontal)
    }

    private var symbolGrid: some View {
        LazyVGrid(columns: self.columns, spacing: 12) {
            ForEach(SymbolCatalog.ids, id: \.self) { symbol in
                self.symbolButton(symbol)
            }
        }
        .padding(.horizontal)
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: self.cellSize, maximum: self.cellSize * 1.4), spacing: 12)]
    }

    private func emojiButton(_ item: EmojiItem) -> some View {
        let isSelected = self.icon == item.emoji
        return Button {
            self.icon = item.emoji
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? self.color.color.opacity(0.15) : Color.clear)
                    .frame(width: self.cellSize, height: self.cellSize)
                Text(verbatim: item.emoji)
                    .font(.system(size: self.cellFont))
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

    private func symbolButton(_ symbol: String) -> some View {
        let isSelected = self.icon == symbol
        return Button {
            self.icon = symbol
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? self.color.color.opacity(0.15) : Color.clear)
                    .frame(width: self.cellSize, height: self.cellSize)
                Image(systemName: symbol)
                    .font(.system(size: self.cellFont))
                    .foregroundStyle(isSelected ? self.color.color : .secondary)
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(self.color.color, lineWidth: 2)
                        .frame(width: self.cellSize, height: self.cellSize)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symbol)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
