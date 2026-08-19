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

    static func suggestionAppearAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .smooth
    }
}

/// Vertical expand from the top. Reduce Motion keeps a fade and skips the scale.
struct IconPickerSuggestionAppear: Transition {
    var reduceMotion: Bool

    func body(content: Content, phase: TransitionPhase) -> some View {
        let visible = phase.isIdentity
        content
            .opacity(visible ? 1 : 0)
            .mask(alignment: .top) {
                Rectangle()
                    .scaleEffect(
                        y: (visible || self.reduceMotion) ? 1 : 0,
                        anchor: .top)
            }
    }
}
