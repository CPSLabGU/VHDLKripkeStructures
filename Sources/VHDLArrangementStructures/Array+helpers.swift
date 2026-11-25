import Foundation
import VHDLMachines
import VHDLParsing

/// Add cartesian product.
extension Array where Element: Collection {
    /// The cartesian product of the array of collections.
    ///
    /// For example, `[[1, 2], [3, 4]].cartesianProduct` will produce `[[1, 3], [1, 4], [2, 3], [2, 4]]`.
    var cartesianProduct: [[Element.Element]] {
        self.reduce(into: [[]]) { matrix, array in
            matrix = matrix.flatMap { row in
                array.map { element in
                    row + [element]
                }
            }
        }
    }
}

/// Add concurrent map.
extension Collection where Self: Sendable, Element: Sendable, Index == Int {
    /// Performs a concurrent map operation on the array.
    func concurrentMap<Output: Sendable>(
        _ transform: @escaping @Sendable (Element) async -> Output
    ) async -> [Output] {
        guard !isEmpty else {
            return []
        }
        let workerCount = Swift.min(count, ProcessInfo.processInfo.activeProcessorCount)
        return await withTaskGroup(of: (Int, [Output]).self) { group in
            for worker in 0..<workerCount {
                let start = count / workerCount * worker + Swift.min(worker, count % workerCount)
                let end = start + count / workerCount + (worker < count % workerCount ? 1 : 0)
                group.addTask {
                    var results: [Output] = []
                    results.reserveCapacity(end - start)
                    var index = self.index(self.startIndex, offsetBy: start)
                    for _ in start..<end {
                        results.append(await transform(self[index]))
                        self.formIndex(after: &index)
                    }
                    return (worker, results)
                }
            }
            var batches: [[Output]] = .init(repeating: [], count: workerCount)
            for await (worker, results) in group {
                batches[worker] = results
            }
            return batches.flatMap { $0 }
        }
    }

    /// A filter that executes concurrently on the array elements.
    func concurrentFilter(_ isIncluded: @escaping @Sendable (Element) async -> Bool) async -> [Element] {
        guard !isEmpty else {
            return []
        }
        let workerCount = Swift.min(count, ProcessInfo.processInfo.activeProcessorCount)
        return await withTaskGroup(of: (Self.Index, [Element]).self) { group in
            for worker in 0..<workerCount {
                let start = count / workerCount * worker + Swift.min(worker, count % workerCount)
                let end = start + count / workerCount + (worker < count % workerCount ? 1 : 0)
                group.addTask {
                    var results: [Element] = []
                    results.reserveCapacity(end - start)
                    var index = self.index(self.startIndex, offsetBy: start)
                    for _ in start..<end {
                        let element = self[index]
                        if await isIncluded(element) {
                            results.append(element)
                        }
                        self.formIndex(after: &index)
                    }
                    return (worker, results)
                }
            }
            var batches: [[Element]] = .init(repeating: [], count: workerCount)
            for await (worker, results) in group {
                batches[worker] = results
            }
            return batches.flatMap { $0 }
        }
    }
}

/// Add concurrent cartesian product.
extension Array where Element: Collection & Sendable, Element.Element: Sendable {
    /// Evaluates the concurrent cartesian product of the array of collections.
    fileprivate var concurrentCartesianProduct: [[Element.Element]] {
        get async {
            var matrix: [[Element.Element]] = [[]]
            for collection in self {
                let rows = matrix
                let elements = [Element.Element](collection)
                let indices = [Int](0..<(rows.count * elements.count))
                matrix = await indices.concurrentMap { index in
                    rows[index / elements.count] + [elements[index % elements.count]]
                }
            }
            return matrix
        }
    }
}
