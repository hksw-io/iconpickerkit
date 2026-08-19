import IconPickerKit
import SwiftUI

struct DemoRoot: View {
    @State private var pane = DemoPane.catalog
    @State private var icon = "folder"
    @State private var color = IconPickerColor.blue
    @State private var hint = "French"
    @State private var delaySuggestions = true
    @State private var showingInspector = true
    @State private var generation = 0
    @State private var suggestionTask: Task<IconSuggestions, Never>? = DemoSuggestions.makeTask(
        hint: "French",
        delay: true)

    var body: some View {
        DemoPaneHost(
            pane: self.pane,
            icon: self.$icon,
            color: self.$color,
            suggestionTask: self.suggestionTask)
            .id(self.generation)
            .inspector(isPresented: self.$showingInspector) {
                DemoInspector(
                    hint: self.$hint,
                    delaySuggestions: self.$delaySuggestions,
                    icon: self.icon,
                    color: self.color,
                    onReload: self.reload)
                    .inspectorColumnWidth(min: 200, ideal: 240, max: 300)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Pane", selection: self.$pane) {
                        ForEach(DemoPane.allCases) { pane in
                            Text(pane.title).tag(pane)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 240)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Reload", action: self.reload)
                }
            }
            .onChange(of: self.delaySuggestions) { _, _ in
                self.reload()
            }
            .navigationTitle("IconPickerKit")
    }

    private func reload() {
        self.generation += 1
        self.suggestionTask = DemoSuggestions.makeTask(
            hint: self.hint,
            delay: self.delaySuggestions)
    }
}

private enum DemoPane: String, CaseIterable, Identifiable {
    case catalog
    case row

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .catalog: "Catalog"
        case .row: "Form row"
        }
    }
}

private struct DemoPaneHost: View {
    let pane: DemoPane
    @Binding var icon: String
    @Binding var color: IconPickerColor
    let suggestionTask: Task<IconSuggestions, Never>?

    var body: some View {
        switch self.pane {
        case .catalog:
            DemoCatalogPane(
                icon: self.$icon,
                color: self.$color,
                suggestionTask: self.suggestionTask)
        case .row:
            DemoRowPane(icon: self.$icon, color: self.$color)
        }
    }
}

private struct DemoCatalogPane: View {
    @Binding var icon: String
    @Binding var color: IconPickerColor
    let suggestionTask: Task<IconSuggestions, Never>?

    var body: some View {
        IconPickerView(
            icon: self.$icon,
            color: self.$color,
            allowsCustomColor: true,
            suggestions: self.suggestionTask)
    }
}

private struct DemoRowPane: View {
    @Binding var icon: String
    @Binding var color: IconPickerColor

    var body: some View {
        Form {
            IconPickerRow(
                icon: self.$icon,
                color: self.$color,
                allowsCustomColor: true)
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct DemoInspector: View {
    @Binding var hint: String
    @Binding var delaySuggestions: Bool
    let icon: String
    let color: IconPickerColor
    let onReload: () -> Void

    var body: some View {
        Form {
            Section("Suggestions") {
                TextField("Hint", text: self.$hint, prompt: Text("Deck name"))
                    .onSubmit(self.onReload)
                Toggle("Delay 2 seconds", isOn: self.$delaySuggestions)
                Text(
                    "Delay starts canned suggestions after 2 seconds so you can scroll first. The visible icons should stay put."
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            Section("Selection") {
                LabeledContent("Icon", value: self.icon)
                LabeledContent("Color", value: self.color.name)
            }
        }
        .formStyle(.grouped)
    }
}

private enum DemoSuggestions {
    static let canned = ["🇫🇷", "🥖", "flag", "book", "globe.europe.africa"]

    static func makeTask(hint: String, delay: Bool) -> Task<IconSuggestions, Never>? {
        let trimmed = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if delay {
            return IconSuggestions.preload(hint: trimmed) { _ in
                try await Task.sleep(for: .seconds(2))
                return self.canned
            }
        }
        return IconSuggestions.preload(hint: trimmed)
    }
}
