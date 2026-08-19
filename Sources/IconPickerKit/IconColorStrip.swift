import SwiftUI

struct IconColorStrip: View {
    @Binding var color: IconPickerColor
    var colors: [IconPickerColor]
    var allowsCustomColor: Bool
    var customLabel: String
    var swatchSize: CGFloat
    var contentInset: CGFloat = IconPickerLayout.horizontalInset

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: IconPickerLayout.stackSpacing) {
                ForEach(self.colors) { swatch in
                    self.presetSwatch(swatch)
                }
                if self.allowsCustomColor {
                    self.customSwatch
                }
            }
            .padding(.leading, self.contentInset)
            .padding(.trailing, self.contentInset)
        }
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
        let binding = Binding<Color>(
            get: { self.color.color },
            set: { self.color = .custom($0) })
        return ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red],
                        center: .center))
            ColorPicker(self.customLabel, selection: binding, supportsOpacity: false)
                .labelsHidden()
                .opacity(0.02)
                .scaleEffect(2)
        }
        .frame(width: self.swatchSize, height: self.swatchSize)
        .clipShape(Circle())
        .overlay {
            if self.color.isCustom {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(width: self.swatchSize - 4, height: self.swatchSize - 4)
            }
        }
        .iconPickerHover()
        .help(self.customLabel)
        .accessibilityLabel(self.customLabel)
        .accessibilityAddTraits(self.color.isCustom ? [.isButton, .isSelected] : .isButton)
    }

    private func circle(_ fill: Color, selected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(fill)
                .frame(width: self.swatchSize, height: self.swatchSize)
            if selected {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(width: self.swatchSize - 4, height: self.swatchSize - 4)
            }
        }
        .frame(width: self.swatchSize, height: self.swatchSize)
        .contentShape(Circle())
    }
}
