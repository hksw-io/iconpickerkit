import IconPickerKit
import IconPickerKitIntelligence
import SwiftUI

struct DemoRoot: View {
    @State private var pane = DemoPane.catalog
    @State private var icon = "folder"
    @State private var color = IconPickerColor.blue
    @State private var hint = "French"
    @State private var delaySuggestions = true
    @State private var showingInspector = true
    @State private var generation = 0
    @State private var appliedHint = "French"
    @State private var canned = IconSuggestions.empty

    var body: some View {
        DemoPaneHost(
            pane: self.pane,
            icon: self.$icon,
            color: self.$color,
            hint: self.delaySuggestions ? nil : self.appliedHint,
            suggestions: self.canned)
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
            .task(id: self.generation) {
                self.canned = .empty
                guard self.delaySuggestions else { return }
                let loaded = await IconSuggestions.load(hint: self.appliedHint) { _ in
                    try await Task.sleep(for: .seconds(2))
                    return ["🇫🇷", "🥖", "flag", "book", "globe.europe.africa"]
                }
                if !Task.isCancelled {
                    self.canned = loaded
                }
            }
    }

    private func reload() {
        self.generation += 1
        self.appliedHint = self.hint
    }
}

extension IconPickerLabels {
    /// The demo speaks English only. An app passes its localized strings, as in the README.
    static let demo = IconPickerLabels(
        color: "Color",
        icon: "Icon",
        search: "Search Icons",
        clear: "Clear",
        noIcons: "No Icons",
        groupTitle: { $0.rawValue.capitalized },
        colorName: { $0.id.capitalized })
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
    let hint: String?
    let suggestions: IconSuggestions

    var body: some View {
        switch self.pane {
        case .catalog:
            DemoCatalogPane(
                icon: self.$icon,
                color: self.$color,
                hint: self.hint,
                suggestions: self.suggestions)
        case .row:
            DemoRowPane(icon: self.$icon, color: self.$color)
        }
    }
}

private struct DemoCatalogPane: View {
    @Binding var icon: String
    @Binding var color: IconPickerColor
    /// Set to ask the on-device model. `nil` shows the canned `suggestions`.
    let hint: String?
    let suggestions: IconSuggestions

    var body: some View {
        if let hint {
            IconPickerView(
                icon: self.$icon,
                color: self.$color,
                catalog: DemoIcons.catalog,
                hint: hint,
                labels: .demo,
                image: DemoIcons.image)
        } else {
            IconPickerView(
                icon: self.$icon,
                color: self.$color,
                catalog: DemoIcons.catalog,
                suggestions: self.suggestions,
                labels: .demo,
                image: DemoIcons.image)
        }
    }
}

/// A section of the demo's own, as an app would add one. SF Symbols stand in for the
/// app's asset images. The form row has no such hook and cannot draw these icons.
private enum DemoIcons {
    static let catalog = IconCatalogPreset(
        groups: IconCatalogPreset.all.groups,
        leading: [
            IconSection(
                id: "demo",
                title: "Demo",
                items: [
                    IconItem(value: "demo-seal", name: "Seal"),
                    IconItem(value: "demo-burst", name: "Burst"),
                ]),
        ])

    static func image(_ item: IconItem) -> Image? {
        switch item.value {
        case "demo-seal": Image(systemName: "seal.fill")
        case "demo-burst": Image(systemName: "burst.fill")
        default: nil
        }
    }
}

private struct DemoRowPane: View {
    @Binding var icon: String
    @Binding var color: IconPickerColor

    var body: some View {
        Form {
            IconPickerRow(icon: self.$icon, color: self.$color, labels: .demo)
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
                LabeledContent("Color", value: IconPickerLabels.demo.colorName(self.color))
            }
        }
        .formStyle(.grouped)
    }
}
