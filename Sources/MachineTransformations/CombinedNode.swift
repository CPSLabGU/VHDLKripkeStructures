import VHDLKripkeStructures
import VHDLParsing

/// A collection of nodes that need to be processed when creating an Arrangements Kripke structure.
struct CombinedNode: Hashable, Codable, Sendable, Equatable {
    /// The nodes sharing the same instance of execution.
    let nodes: [Node]

    /// The name of the instance associated with these nodes.
    let instanceNames: [VariableName]

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

    /// Initialise the combined node.
    init(nodes: [Node], instanceNames: [VariableName]) {
        guard !nodes.isEmpty, nodes.count == instanceNames.count else {
            fatalError("The number of nodes must match the number of instance names.")
        }
        self.nodes = nodes
        self.instanceNames = instanceNames
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
