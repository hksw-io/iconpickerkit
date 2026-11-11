import AppKit
import SwiftUI

@main
struct IconPickerKitDemoApp: App {
    @NSApplicationDelegateAdaptor(DemoAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DemoRoot()
            }
        }
        .defaultSize(width: 760, height: 800)
    }
}

private final class DemoAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
