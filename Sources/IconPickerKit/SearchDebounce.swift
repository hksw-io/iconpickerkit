/// Collapses rapid search keystrokes into one applied query after a pause.
public struct SearchDebounce: Sendable, Equatable {
    public static let interval: Duration = .milliseconds(250)

    public private(set) var applied: String
    public let interval: Duration
    private var pending: String
    private var lastChange: Duration

    public init(applied: String = "", interval: Duration = SearchDebounce.interval) {
        self.applied = applied
        self.pending = applied
        self.interval = interval
        self.lastChange = .zero
    }

    public mutating func push(_ query: String, at time: Duration) {
        self.pending = query
        self.lastChange = time
    }

    public mutating func flush(at time: Duration) {
        if time - self.lastChange >= self.interval {
            self.applied = self.pending
        }
    }
}
