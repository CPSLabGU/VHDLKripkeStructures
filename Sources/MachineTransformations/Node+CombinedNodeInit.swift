import VHDLKripkeStructures
import VHDLMachines

/// Add conversion from ``CombinedNode``.
extension Node {
    /// Conversion from ``CombinedNode``.
    convenience init(node: CombinedNode) {
        self.init(
            type: node.type,
            currentState: node.name,
            executeOnEntry: node.executeOnEntry,
            nextState: node.nextState,
            properties: node.properties()
        )
    }

    /// Conversion from ``CombinedNode``.
    convenience init(node: CombinedNode, arrangement: Arrangement) {
        self.init(
            type: node.type,
            currentState: node.name,
            executeOnEntry: node.executeOnEntry,
            nextState: node.nextState,
            properties: node.properties(arrangement: arrangement)
        )
    }
}
