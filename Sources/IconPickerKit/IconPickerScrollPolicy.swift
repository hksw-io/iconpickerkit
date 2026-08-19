enum IconPickerScrollPolicy {
    static var isShortForm: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    static func shouldScrollToSelection(
        userHasScrolled: Bool,
        shortForm: Bool = isShortForm) -> Bool
    {
        !userHasScrolled && !shortForm
    }
}
