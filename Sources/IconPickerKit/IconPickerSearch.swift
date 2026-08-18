import SwiftUI

struct IconPickerSearchField: View {
    @Binding var text: String
    @Binding var debounce: SearchDebounce
    var origin: ContinuousClock.Instant
    var prompt: String

    var body: some View {
        PlatformSearchField(text: self.$text, prompt: self.prompt)
            .frame(minHeight: 28)
            .onChange(of: self.text) { _, new in
                self.debounce.push(new, at: ContinuousClock.now - self.origin)
            }
            .task(id: self.text) {
                try? await Task.sleep(for: self.debounce.interval)
                guard !Task.isCancelled else { return }
                self.debounce.flush(at: ContinuousClock.now - self.origin)
            }
    }
}

#if os(macOS)
import AppKit

struct PlatformSearchField: NSViewRepresentable {
    @Binding var text: String
    var prompt: String

    func makeNSView(context: Context) -> NSSearchField {
        let field = NSSearchField()
        field.placeholderString = self.prompt
        field.delegate = context.coordinator
        field.sendsSearchStringImmediately = true
        field.sendsWholeSearchString = false
        return field
    }

    func updateNSView(_ field: NSSearchField, context: Context) {
        if field.stringValue != self.text {
            field.stringValue = self.text
        }
        field.placeholderString = self.prompt
        context.coordinator.text = self.$text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: self.$text)
    }

    final class Coordinator: NSObject, NSSearchFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func controlTextDidChange(_ notification: Notification) {
            let field = notification.object as? NSSearchField
            self.text.wrappedValue = field?.stringValue ?? ""
        }
    }
}
#else
import UIKit

struct PlatformSearchField: UIViewRepresentable {
    @Binding var text: String
    var prompt: String

    func makeUIView(context: Context) -> UISearchBar {
        let bar = UISearchBar()
        bar.placeholder = self.prompt
        bar.searchBarStyle = .minimal
        bar.autocapitalizationType = .none
        bar.autocorrectionType = .no
        bar.delegate = context.coordinator
        return bar
    }

    func updateUIView(_ bar: UISearchBar, context: Context) {
        if bar.text != self.text {
            bar.text = self.text
        }
        bar.placeholder = self.prompt
        context.coordinator.text = self.$text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: self.$text)
    }

    final class Coordinator: NSObject, UISearchBarDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text.wrappedValue = searchText
        }
    }
}
#endif
