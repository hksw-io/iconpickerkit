import AppKit
import IconPickerKit
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

@main
struct GenerateMedia {
    @MainActor
    static func main() throws {
        _ = NSApplication.shared

        let out = URL(filePath: FileManager.default.currentDirectoryPath)
            .appending(path: "Docs/Media", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)

        try write(
            ViewShot(scheme: .light),
            size: CGSize(width: 390, height: 780),
            appearance: .aqua,
            to: out.appending(path: "iconpickerkit-view-light.png"))
        try write(
            ViewShot(scheme: .dark),
            size: CGSize(width: 390, height: 780),
            appearance: .darkAqua,
            to: out.appending(path: "iconpickerkit-view-dark.png"))
        try write(
            RowShot(scheme: .light),
            size: CGSize(width: 580, height: 100),
            appearance: .aqua,
            to: out.appending(path: "iconpickerkit-row-light.png"))
        try write(
            RowShot(scheme: .dark),
            size: CGSize(width: 580, height: 100),
            appearance: .darkAqua,
            to: out.appending(path: "iconpickerkit-row-dark.png"))
        try write(
            SuggestionsShot(scheme: .light),
            size: CGSize(width: 390, height: 780),
            appearance: .aqua,
            to: out.appending(path: "iconpickerkit-view-suggestions-light.png"))
        try write(
            SuggestionsShot(scheme: .dark),
            size: CGSize(width: 390, height: 780),
            appearance: .darkAqua,
            to: out.appending(path: "iconpickerkit-view-suggestions-dark.png"))
    }

    @MainActor
    private static func write(
        _ view: some View,
        size: CGSize,
        appearance: NSAppearance.Name,
        to url: URL) throws
    {
        let hosting = NSHostingView(
            rootView: view
                .frame(width: size.width, height: size.height)
                .background(Color(nsColor: .windowBackgroundColor)))
        hosting.appearance = NSAppearance(named: appearance)
        hosting.frame = NSRect(origin: .zero, size: size)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: appearance)
        window.backgroundColor = .windowBackgroundColor
        window.contentView = hosting
        window.orderFrontRegardless()
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        CFRunLoopRunInMode(.defaultMode, 0.05, false)
        hosting.layoutSubtreeIfNeeded()

        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            throw Exit("could not cache \(url.lastPathComponent)")
        }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        window.orderOut(nil)
        guard let image = rep.cgImage else {
            throw Exit("could not render \(url.lastPathComponent)")
        }
        guard
            let destination = CGImageDestinationCreateWithURL(
                url as CFURL,
                UTType.png.identifier as CFString,
                1,
                nil)
        else {
            throw Exit("could not write \(url.path)")
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw Exit("could not finalize \(url.lastPathComponent)")
        }
        print(url.path)
    }
}

private struct ViewShot: View {
    @State private var icon = "folder"
    @State private var color = IconPickerColor.blue
    let scheme: ColorScheme

    var body: some View {
        IconPickerView(icon: self.$icon, color: self.$color, allowsCustomColor: true)
            .preferredColorScheme(self.scheme)
    }
}

private struct SuggestionsShot: View {
    @State private var icon = "🇫🇷"
    @State private var color = IconPickerColor.blue
    let scheme: ColorScheme

    var body: some View {
        IconPickerView(
            icon: self.$icon,
            color: self.$color,
            allowsCustomColor: true,
            suggestions: IconSuggestions(items: [
                IconItem(value: "🇫🇷", name: "France"),
                IconItem(value: "🥖", name: "Baguette"),
                IconItem(value: "flag", name: "flag"),
                IconItem(value: "book", name: "book"),
                IconItem(value: "globe.europe.africa", name: "globe europe africa"),
            ]))
            .preferredColorScheme(self.scheme)
    }
}

private struct RowShot: View {
    @State private var icon = "folder"
    @State private var color = IconPickerColor.blue
    let scheme: ColorScheme

    var body: some View {
        Form {
            IconPickerRow(icon: self.$icon, color: self.$color, allowsCustomColor: true)
        }
        .formStyle(.grouped)
        .preferredColorScheme(self.scheme)
    }
}

private struct Exit: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}
