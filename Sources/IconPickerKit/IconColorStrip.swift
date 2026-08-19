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
        #if os(macOS)
        Button(action: self.openSystemColorPanel) {
            self.customSwatchChrome
        }
        .buttonStyle(.plain)
        .iconPickerHover()
        .help(self.customLabel)
        .accessibilityLabel(self.customLabel)
        .accessibilityAddTraits(self.color.isCustom ? [.isButton, .isSelected] : .isButton)
        #else
        ZStack {
            self.customSwatchChrome
            ColorPicker(
                self.customLabel,
                selection: self.customColorBinding,
                supportsOpacity: false)
                .labelsHidden()
                .opacity(0.02)
                .scaleEffect(2)
        }
        .clipShape(Circle())
        .iconPickerHover()
        .help(self.customLabel)
        .accessibilityLabel(self.customLabel)
        .accessibilityAddTraits(self.color.isCustom ? [.isButton, .isSelected] : .isButton)
        #endif
    }

    private var customSwatchChrome: some View {
        Circle()
            .fill(
                AngularGradient(
                    colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red],
                    center: .center))
            .padding(self.color.isCustom ? IconPickerSwatchRing.fillInset : 0)
            .frame(width: self.swatchSize, height: self.swatchSize)
            .clipShape(Circle())
            .overlay {
                if self.color.isCustom {
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: IconPickerSwatchRing.lineWidth)
                }
            }
            .contentShape(Circle())
    }

    #if !os(macOS)
    private var customColorBinding: Binding<Color> {
        Binding(
            get: { self.color.color },
            set: { self.color = .custom($0) })
    }
    #endif

    #if os(macOS)
    private func openSystemColorPanel() {
        let current = self.color.color
        if !self.color.isCustom {
            self.color = .custom(current)
        }
        IconPickerColorPanel.present(color: current) { picked in
            self.color = .custom(picked)
        }
    }
    #endif

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
