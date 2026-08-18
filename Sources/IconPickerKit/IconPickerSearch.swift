import SwiftUI

extension View {
    func iconPickerSearch(
        text: Binding<String>,
        debounce: Binding<SearchDebounce>,
        origin: ContinuousClock.Instant,
        prompt: String) -> some View
    {
        self
            .searchable(text: text, prompt: Text(prompt))
            .onChange(of: text.wrappedValue) { _, new in
                debounce.wrappedValue.push(new, at: ContinuousClock.now - origin)
            }
            .task(id: text.wrappedValue) {
                try? await Task.sleep(for: debounce.wrappedValue.interval)
                guard !Task.isCancelled else { return }
                debounce.wrappedValue.flush(at: ContinuousClock.now - origin)
            }
    }
}
