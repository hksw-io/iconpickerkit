import SwiftUI

struct IconColorStrip: View {
    @Binding var color: IconPickerColor
    var colors: [IconPickerColor]
    var swatchSize: CGFloat
    var contentInset: CGFloat = IconPickerLayout.horizontalInset
    var colorNames: [String: String] = [:]

    var body: some View {
        let overflow = IconPickerHover.overflow(for: self.swatchSize)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: IconPickerLayout.stackSpacing) {
                ForEach(self.colors) { swatch in
                    self.presetSwatch(swatch)
                }
            }
            .padding(.vertical, overflow)
            .padding(.leading, self.contentInset + overflow)
            .padding(.trailing, self.contentInset + overflow)
        }
        .scrollClipDisabled()
    }

    private func presetSwatch(_ swatch: IconPickerColor) -> some View {
        let name = self.colorNames[swatch.id] ?? swatch.name
        let isSelected = self.color.id == swatch.id
        return Button {
            self.color = swatch
        } label: {
            self.circle(swatch.color, selected: isSelected)
                .frame(
                    width: IconPickerLayout.hitSize(for: self.swatchSize),
                    height: IconPickerLayout.hitSize(for: self.swatchSize))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .iconPickerHover()
        .help(name)
        .accessibilityLabel(name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func circle(_ fill: Color, selected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(fill)
                .padding(selected ? IconPickerSwatchRing.fillInset : 0)
            if selected {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: IconPickerSwatchRing.lineWidth)
            }
        }
        .frame(width: self.swatchSize, height: self.swatchSize)
        .contentShape(Circle())
    }
}
