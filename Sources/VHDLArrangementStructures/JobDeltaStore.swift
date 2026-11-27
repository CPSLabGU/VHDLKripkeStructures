/// The store of job deltas.
struct JobDeltaStore {
    /// The underlying store.
    private var store = [Int](repeating: 0, count: 10)

    /// The next index to insert a delta at.
    private var nextIndex = 0

    /// The average of the stored deltas.
    var average: Int {
        store.reduce(0, +) / store.count
    }

    /// Default init.
    init() {}

    /// Append a new value
    mutating func append(delta: Int) {
        store[nextIndex] = delta
        nextIndex = (nextIndex + 1) % store.count
    }
}
