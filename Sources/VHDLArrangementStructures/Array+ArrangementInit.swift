import VHDLMachines

/// Add initialisation of a combined node.
extension Array where Element == CombinedNode {

    /// Combined nodes from multiple kripke structures in arrangement.
    init(nodes: [[ScopedNode]], arrangement: Arrangement) {
        guard !nodes.isEmpty, nodes.allSatisfy({ !$0.isEmpty }) else {
            fatalError("Passed empty array when constructing combined kripke structure.")
        }
        guard nodes.count > 1 else {
            self = nodes[0].map { CombinedNode(scopedNodes: [$0]) }
            return
        }
        let firstNodes = nodes[0]
        var combinedNodes: [CombinedNode] = []
        for currentNode in firstNodes {
            var candidates: [[ScopedNode]] = []
            candidates.reserveCapacity(nodes.count)
            candidates.append([currentNode])
            for otherStructureIndex in 1..<nodes.count {
                candidates.append(
                    nodes[otherStructureIndex]
                        .filter {
                            currentNode.node.type == $0.node.type
                                && currentNode.hasSameExternals(as: $0, in: arrangement)
                        }
                )
            }
            combinedNodes.append(
                contentsOf: candidates.cartesianProduct.map { CombinedNode(scopedNodes: $0) }
            )
        }
        self = combinedNodes
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
