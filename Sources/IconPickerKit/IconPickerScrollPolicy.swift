import SwiftUI

enum IconPickerScrollPolicy {
    static var isShortForm: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    static let layoutSettle: Duration = .milliseconds(16)

    /// Appear-scroll is independent of suggestion loading so the catalog
    /// does not sit at the top until the on-device model returns.
    static func shouldScrollToSelection(
        userHasScrolled: Bool,
        selectionIsVisible: Bool = false,
        shortForm: Bool = isShortForm) -> Bool
    {
        !userHasScrolled && !selectionIsVisible && !shortForm
    }

    static func scrollAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .smooth
    }

    static let catalogTopSlop: CGFloat = 8

    static func catalogIsAtTop(
        offsetY: CGFloat,
        insetTop: CGFloat,
        slop: CGFloat = catalogTopSlop) -> Bool
    {
        offsetY <= insetTop + slop
    }

    /// Expand only while the catalog is still at the top. A scrolled catalog
    /// keeps its visible identity, so an insert above it would otherwise jitter.
    static func suggestionAppearAnimation(
        reduceMotion: Bool,
        catalogIsAtTop: Bool = true) -> Animation?
    {
        reduceMotion || !catalogIsAtTop ? nil : .smooth
    }

    static func colorChromeAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .smooth
    }
}

/// Expand from an edge. Reduce Motion keeps a fade and skips the scale.
struct IconPickerExpand: Transition {
    var reduceMotion: Bool
    var axis: Axis
    var anchor: UnitPoint

    static func vertical(reduceMotion: Bool) -> Self {
        Self(reduceMotion: reduceMotion, axis: .vertical, anchor: .top)
    }

    static func horizontal(reduceMotion: Bool) -> Self {
        Self(reduceMotion: reduceMotion, axis: .horizontal, anchor: .leading)
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        let visible = phase.isIdentity
        let x: CGFloat = (self.axis == .horizontal && !visible && !self.reduceMotion) ? 0 : 1
        let y: CGFloat = (self.axis == .vertical && !visible && !self.reduceMotion) ? 0 : 1
        content
            .opacity(visible ? 1 : 0)
            .mask(alignment: self.maskAlignment) {
                Rectangle()
                    .scaleEffect(x: x, y: y, anchor: self.anchor)
            }
    }

    private var maskAlignment: Alignment {
        switch self.axis {
        case .vertical: .top
        case .horizontal: .leading
        }
    }
}
