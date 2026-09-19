import SwiftUI

struct IconColorStrip: View {
    @Binding var color: IconPickerColor
    var colors: [IconPickerColor]
    var allowsCustomColor: Bool
    var customLabel: String
    var swatchSize: CGFloat
    var contentInset: CGFloat = IconPickerLayout.horizontalInset

    var body: some View {
        let overflow = IconPickerHover.overflow(for: self.swatchSize)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: IconPickerLayout.stackSpacing) {
                ForEach(self.colors) { swatch in
                    self.presetSwatch(swatch)
                }
                if self.allowsCustomColor {
                    self.customSwatch
                }
            }
            .padding(.vertical, overflow)
            .padding(.leading, self.contentInset + overflow)
            .padding(.trailing, self.contentInset + overflow)
        }
        .scrollClipDisabled()
    }

    private func presetSwatch(_ swatch: IconPickerColor) -> some View {
        let isSelected = !self.color.isCustom && self.color.id == swatch.id
        return Button {
            self.color = swatch
        } label: {
            self.circle(swatch.color, selected: isSelected)
        }
        .buttonStyle(.plain)
        .iconPickerHover()
        .help(swatch.name)
        .accessibilityLabel(swatch.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var customSwatch: some View {
        ColorPicker(
            self.customLabel,
            selection: self.customColorBinding,
            supportsOpacity: false)
            .labelsHidden()
            .frame(minWidth: self.swatchSize, minHeight: self.swatchSize)
            .help(self.customLabel)
            .accessibilityAddTraits(self.color.isCustom ? .isSelected : [])
    }

    private var customColorBinding: Binding<Color> {
        Binding(
            get: { self.color.color },
            set: { self.color = .custom($0) })
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
