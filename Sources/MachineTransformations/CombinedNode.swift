import VHDLKripkeStructures
import VHDLParsing

/// A collection of nodes that need to be processed when creating an Arrangements Kripke structure.
final class CombinedNode: Hashable, Codable, Sendable, Equatable {
    /// The nodes sharing the same instance of execution.
    let nodes: [Node]

    /// The name of the instance associated with these nodes.
    let instanceNames: [VariableName]

    /// The type of the combined node.
    let type: NodeType

    /// Whether all nodes in the combined node execute onEntry.
    var executeOnEntry: Bool {
        nodes.allSatisfy(\.executeOnEntry)
    }

    /// The name of the combined node.
    var name: VariableName {
        let rawName = zip(instanceNames, nodes)
            .map {
                "\($0.0.rawValue)_\($0.1.currentState.rawValue)"
            }
            .joined(separator: "__")
        // swiftlint:disable:next force_unwrapping
        return VariableName(rawValue: rawName)!
    }

    /// The name of the next state.
    var nextState: VariableName {
        let nextStates = zip(instanceNames, nodes.map(\.nextState))
            .map { "\($0.0.rawValue)_\($0.1.rawValue)" }
            .joined(separator: "__")
        // swiftlint:disable:next force_unwrapping
        return VariableName(rawValue: nextStates)!
    }

    /// Initialise the combined node.
    init(nodes: [Node], instanceNames: [VariableName]) {
        guard !nodes.isEmpty, nodes.count == instanceNames.count,
            nodes.allSatisfy({ $0.type == nodes[0].type })
        else {
            fatalError(
                "The nodes are invalid. The number of nodes must match the number of instance names "
                    + "and must all have the same type."
            )
        }
        self.nodes = nodes
        self.instanceNames = instanceNames
        self.type = nodes[0].type
    }

    /// Conversion init.
    convenience init(scopedNodes: [ScopedNode]) {
        self.init(nodes: scopedNodes.map { $0.node }, instanceNames: scopedNodes.map { $0.instanceName })
    }

    /// Equality conformance.
    static func == (lhs: CombinedNode, rhs: CombinedNode) -> Bool {
        lhs.nodes == rhs.nodes && lhs.instanceNames == rhs.instanceNames
    }

    /// Hashing function.
    func hash(into hasher: inout Hasher) {
        hasher.combine(nodes)
        hasher.combine(instanceNames)
    }

    /// Derive the scoped properties for the combined node.
    func properties(excluding: [VariableName: Set<VariableName>] = [:]) -> [VariableName: SignalLiteral] {
        let nodes = zip(self.instanceNames, self.nodes)
        var properties: [VariableName: SignalLiteral] = [:]
        for (instanceName, node) in nodes {
            let excludeList = excluding[instanceName] ?? []
            for (propertyName, propertyValue) in node.properties where !excludeList.contains(propertyName) {
                // swiftlint:disable:next force_unwrapping
                let newName = VariableName(rawValue: "\(instanceName.rawValue)_\(propertyName.rawValue)")!
                properties[newName] = propertyValue
            }
        }
        return properties
    }
}
