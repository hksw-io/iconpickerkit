import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum IconPickerSwatchRing {
    static func color(for fill: Color, scheme: ColorScheme) -> Color {
        self.luminance(of: fill, scheme: scheme) > 0.6 ? Color.black.opacity(0.75) : Color.white
    }

    static func luminance(of fill: Color, scheme: ColorScheme) -> CGFloat {
        #if canImport(AppKit)
        let appearance = NSAppearance(named: scheme == .dark ? .darkAqua : .aqua)
        var value: CGFloat = 0
        appearance?.performAsCurrentDrawingAppearance {
            guard let rgb = NSColor(fill).usingColorSpace(.sRGB) else { return }
            value =
                0.2126 * rgb.redComponent
                + 0.7152 * rgb.greenComponent
                + 0.0722 * rgb.blueComponent
        }
        return value
        #elseif canImport(UIKit)
        let trait = UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(fill).resolvedColor(with: trait).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
        #else
        return scheme == .dark ? 0 : 1
        #endif
    }
}
