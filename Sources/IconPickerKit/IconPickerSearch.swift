import SwiftUI

struct IconPickerSearchField: View {
    @Binding var text: String
    @Binding var debounce: SearchDebounce
    var origin: ContinuousClock.Instant
    var prompt: String
    var autofocus: Bool = false
    var clearLabel: String = "Clear"
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(self.prompt, text: self.$text)
                .font(.body)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
            if !self.text.isEmpty {
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(self.clearLabel)
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(height: IconPickerLayout.searchHeight)
        .background(.quaternary, in: Capsule())
        .focused(self.$focused)
        .onAppear {
            if self.autofocus {
                self.focused = true
            }
        }
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

struct IconPickerEmptyState: View {
    let query: String
    let noIcons: String

    var body: some View {
        if self.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ContentUnavailableView {
                Label(self.noIcons, systemImage: "square.grid.2x2")
            }
        } else {
            ContentUnavailableView.search(text: self.query)
        }
    }
}
