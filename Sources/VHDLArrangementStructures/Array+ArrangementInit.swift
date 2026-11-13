import Foundation
import VHDLMachines
import VHDLParsing

/// Add initialisation of a combined node.
extension Array where Element == CombinedNode {

    // /// Combined nodes from multiple kripke structures in arrangement.
    // init(nodes: [[ScopedNode]], arrangement: Arrangement) {
    //     guard !nodes.isEmpty, nodes.allSatisfy({ !$0.isEmpty }) else {
    //         fatalError("Passed empty array when constructing combined kripke structure.")
    //     }
    //     guard nodes.count > 1 else {
    //         self = nodes[0].map { CombinedNode(scopedNodes: [$0]) }
    //         return
    //     }
    //     let firstNodes = nodes[0]
    //     var combinedNodes: [CombinedNode] = []
    //     for currentNode in firstNodes {
    //         var candidates: [[ScopedNode]] = []
    //         candidates.reserveCapacity(nodes.count)
    //         candidates.append([currentNode])
    //         for otherStructureIndex in 1..<nodes.count {
    //             candidates.append(
    //                 nodes[otherStructureIndex]
    //                     .filter {
    //                         currentNode.node.type == $0.node.type
    //                             && currentNode.hasSameExternals(as: $0, in: arrangement)
    //                     }
    //             )
    //         }
    //         combinedNodes.append(
    //             contentsOf: candidates.cartesianProduct.map { CombinedNode(scopedNodes: $0) }
    //         )
    //     }
    //     self = combinedNodes
    // }

    /// Combined nodes from multiple kripke structures in arrangement, computed concurrently.
    init(nodes: [[ScopedNode]], arrangement: Arrangement, globalState: [VariableName: SignalLiteral]) async {
        guard !nodes.isEmpty, nodes.allSatisfy({ !$0.isEmpty }) else {
            fatalError("Passed empty array when constructing combined kripke structure.")
        }
        guard nodes.count > 1 else {
            self = await nodes[0].concurrentMap { CombinedNode(scopedNodes: [$0]) }
            return
        }
        let firstNodes = nodes[0]
        let batches = await firstNodes.concurrentMap { currentNode in
            let matchingNodes = await [[ScopedNode]](nodes.dropFirst())
                .concurrentMap { structureNodes in
                    structureNodes.filter {
                        currentNode.node.type == $0.node.type
                            && currentNode.hasSameExternals(as: $0, in: arrangement, globalState: globalState)
                    }
                }
            let candidates = [[currentNode]] + matchingNodes
            let product = await candidates.concurrentCartesianProduct
            return await product.concurrentMap { CombinedNode(scopedNodes: $0) }
        }
        self = batches.flatMap { $0 }
    }
}

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
