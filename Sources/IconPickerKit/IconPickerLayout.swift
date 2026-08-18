import CoreGraphics

/// Shared spacing and control size for ``IconPickerView``.
enum IconPickerLayout {
    static let stackSpacing: CGFloat = 12
    static let horizontalInset: CGFloat = 16
    static let controlHeight: CGFloat = 28

    static var spacingAboveSearch: CGFloat { self.stackSpacing }
    static var spacingBelowSearch: CGFloat { self.stackSpacing }
    static var searchInset: CGFloat { self.horizontalInset }
    static var modeInset: CGFloat { self.horizontalInset }
    static var labelInset: CGFloat { self.horizontalInset }
    static var catalogInset: CGFloat { self.horizontalInset }
    static var colorStripInset: CGFloat { self.horizontalInset }
    static var searchHeight: CGFloat { self.controlHeight }
    static var modeHeight: CGFloat { self.controlHeight }
}
