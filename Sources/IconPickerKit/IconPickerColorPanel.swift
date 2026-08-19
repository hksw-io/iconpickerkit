#if os(macOS)
import AppKit
import SwiftUI

/// Opens the shared color panel on click. A hidden SwiftUI `ColorPicker`
/// often swallows the first click on Mac.
enum IconPickerColorPanel {
    @MainActor
    static func present(color: Color, apply: @escaping (Color) -> Void) {
        Session.shared.present(color: color, apply: apply)
    }

    @MainActor
    private final class Session {
        static let shared = Session()
        private var apply: ((Color) -> Void)?
        private var token: (any NSObjectProtocol)?

        func present(color: Color, apply: @escaping (Color) -> Void) {
            self.apply = apply
            let panel = NSColorPanel.shared
            panel.showsAlpha = false
            panel.isContinuous = true
            panel.color = NSColor(color)
            if self.token == nil {
                self.token = NotificationCenter.default.addObserver(
                    forName: NSColorPanel.colorDidChangeNotification,
                    object: panel,
                    queue: .main
                ) { _ in
                    Task { @MainActor in
                        Session.shared.emit()
                    }
                }
            }
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate()
        }

        private func emit() {
            self.apply?(Color(nsColor: NSColorPanel.shared.color))
        }
    }
}
#endif
