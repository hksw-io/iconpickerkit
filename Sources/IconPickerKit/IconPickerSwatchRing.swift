import CoreGraphics
import SwiftUI

enum IconPickerSwatchRing {
    static let lineWidth: CGFloat = 2
    static let fillInset: CGFloat = 3

    static func fillSize(swatchSize: CGFloat, selected: Bool) -> CGFloat {
        selected ? swatchSize - 2 * self.fillInset : swatchSize
    }
}
