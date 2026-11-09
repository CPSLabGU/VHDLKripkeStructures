import VHDLMachines

/// Add initialisation of a combined node.
extension Array where Element == CombinedNode {

    // swiftlint:disable function_body_length

    /// Combined nodes from multiple kripke structures in arrangement.
    init(nodes: [[ScopedNode]], arrangement: Arrangement) {
        guard nodes.allSatisfy({ !$0.isEmpty }) else {
            fatalError("Passed empty array when constructing combined kripke structure.")
        }
        self.init(
            accumulator: [],
            nodeIndexes: [Int](repeating: 0, count: nodes.count),
            nodes: nodes,
            arrangement: arrangement
        )
    }

    /// Attempt to combine kripke structures.
    private init(
        accumulator: [CombinedNode],
        nodeIndexes: [Int],
        nodes: [[ScopedNode]],
        arrangement: Arrangement,
    ) {
        guard
            let currentOffset = nodeIndexes.indices.reversed()
                .first(where: {
                    nodes[$0].endIndex > nodeIndexes[$0]
                })
        else {
            self = accumulator
            return
        }
        let currentNodes = nodeIndexes.indices.map {
            nodes[$0][nodeIndexes[$0]]
        }
        let offsetIndex = nodeIndexes[currentOffset]
        let currentOffsetNode = nodes[currentOffset][offsetIndex]
        var accumulator = accumulator
        if currentNodes.allSatisfy({
            $0.hasSameExternals(
                as: currentOffsetNode,
                in: arrangement
            )
        }) {
            accumulator.append(CombinedNode(scopedNodes: currentNodes))
        }
        var newIndexes = nodeIndexes
        newIndexes[currentOffset] += 1
        let endIndex = newIndexes.endIndex
        if newIndexes[currentOffset] >= nodes[currentOffset].endIndex {
            guard currentOffset > 0 else {
                self = accumulator
                return
            }
            newIndexes[currentOffset - 1] += 1
            for i in currentOffset..<endIndex {
                newIndexes[i] = 0
            }
        } else {
            let nextIndex = newIndexes.index(after: currentOffset)
            if nextIndex < endIndex {
                for i in nextIndex..<endIndex {
                    newIndexes[i] = 0
                }
            }
        }
        self.init(
            accumulator: accumulator,
            nodeIndexes: newIndexes,
            nodes: nodes,
            arrangement: arrangement
        )
    }

    // swiftlint:enable function_body_length
}
