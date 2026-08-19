import CoreGraphics
import SwiftUI

/// Shared spacing and control size for ``IconPickerView``.
enum IconPickerLayout {
    static let stackSpacing: CGFloat = 12
    static let horizontalInset: CGFloat = 16
    static let controlHeight: CGFloat = 28
    static let swatchSize: CGFloat = 32
    static let viewCellSize: CGFloat = 44

    static var rowSwatchSize: CGFloat {
        #if os(macOS)
        20
        #else
        24
        #endif
    }

    static var rowIconButtonSize: CGFloat {
        #if os(macOS)
        36
        #else
        44
        #endif
    }

    static var sectionSpacing: CGFloat { self.stackSpacing }
    static var spacingAboveSearch: CGFloat { self.stackSpacing }
    static var spacingBelowSearch: CGFloat { self.stackSpacing }
    static var searchInset: CGFloat { self.horizontalInset }
    static var modeInset: CGFloat { self.horizontalInset }
    static var labelInset: CGFloat { self.horizontalInset }
    static var catalogInset: CGFloat { self.horizontalInset }
    static var colorStripInset: CGFloat { self.horizontalInset }
    static let searchHeight: CGFloat = 36
    static var modeHeight: CGFloat { self.controlHeight }
}

enum IconPickerHover {
    static let amount: CGFloat = 1.12

    static func scale(isHovered: Bool, reduceMotion: Bool) -> CGFloat {
        isHovered && !reduceMotion ? self.amount : 1
    }
}

struct IconPickerHovering: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(
                IconPickerHover.scale(isHovered: self.isHovered, reduceMotion: self.reduceMotion))
            .animation(self.reduceMotion ? nil : .easeInOut(duration: 0.12), value: self.isHovered)
            .onHover { self.isHovered = $0 }
    }
}

extension View {
    func iconPickerHover() -> some View {
        modifier(IconPickerHovering())
    }
}
