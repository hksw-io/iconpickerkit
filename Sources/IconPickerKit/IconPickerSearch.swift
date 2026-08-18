import SwiftUI

struct IconPickerSearchField: View {
    @Binding var text: String
    @Binding var debounce: SearchDebounce
    var origin: ContinuousClock.Instant
    var prompt: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(self.prompt, text: self.$text)
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
                .accessibilityLabel("Clear")
            }
        }
        .padding(.horizontal, 8)
        .frame(height: IconPickerLayout.searchHeight)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
