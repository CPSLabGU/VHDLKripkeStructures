import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// A collection of nodes that need to be processed when creating an Arrangements Kripke structure.
final class CombinedNode: Hashable, Codable, Sendable, Equatable, CustomStringConvertible {
    /// The nodes sharing the same instance of execution.
    let nodes: [Node]

    /// The machine instances associated with these nodes.
    let instances: [MachineInstance]

    /// The name of the instance associated with these nodes.
    var instanceNames: [VariableName] {
        self.instances.map(\.name)
    }

    /// The type of the combined node.
    let type: NodeType

    /// The debug description of the combined node.
    var description: String {
        self.nodes.indices.map { "\(self.instanceNames[$0].rawValue): \(self.nodes[$0].description)" }
            .joined(separator: "\n")
    }

    /// Whether all nodes in the combined node execute onEntry.
    var executeOnEntry: Bool {
        nodes.allSatisfy(\.executeOnEntry)
    }

    /// The name of the combined node.
    var name: VariableName {
        let rawName = zip(instanceNames, nodes)
            .sorted { $0.0 < $1.0 }
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
            .sorted { $0.0 < $1.0 }
            .map { "\($0.0.rawValue)_\($0.1.rawValue)" }
            .joined(separator: "__")
        // swiftlint:disable:next force_unwrapping
        return VariableName(rawValue: nextStates)!
    }

    /// Initialise the combined node.
    convenience init(nodes: [Node], instances: [MachineInstance]) {
        guard nodes.count == instances.count else {
            fatalError("The number of nodes must match the number of instances.")
        }
        let scopedNodes = zip(instances, nodes).map { ScopedNode(instance: $0, node: $1) }
        self.init(scopedNodes: scopedNodes)
    }

    /// Conversion init.
    convenience init(scopedNodes: [ScopedNode]) {
        let sortedNodes = scopedNodes.sorted()
        self.init(nodesSorted: sortedNodes.map { $0.node }, instancesSorted: sortedNodes.map { $0.instance })
    }

    /// Initialise the stored properties.
    private init(nodesSorted: [Node], instancesSorted: [MachineInstance]) {
        guard !nodesSorted.isEmpty, nodesSorted.count == instancesSorted.count,
            nodesSorted.allSatisfy({ $0.type == nodesSorted[0].type }),
            Set(instancesSorted.map(\.name)).count == instancesSorted.count
        else {
            fatalError(
                "The nodes are invalid. The number of nodes must match the number of instance names "
                    + "and must all have the same type."
            )
        }
        self.nodes = nodesSorted
        self.instances = instancesSorted
        self.type = nodesSorted[0].type
    }

    /// Equality conformance.
    static func == (lhs: CombinedNode, rhs: CombinedNode) -> Bool {
        lhs.nodes == rhs.nodes && lhs.instances == rhs.instances
    }

    /// Hashing function.
    func hash(into hasher: inout Hasher) {
        hasher.combine(nodes)
        hasher.combine(instances)
    }

    /// Calculate properties for the combined node that exists in the given arrangement.
    func properties(arrangement: Arrangement) -> [VariableName: SignalLiteral] {
        let excludeDictionary = Dictionary(
            uniqueKeysWithValues: arrangement.reverseExternalMappings.map { ($0.key, Set($0.value.keys)) }
        )
        let scopedProperties = self.properties(excluding: excludeDictionary)
        let mappings = arrangement.externalMappings
        // swiftlint:disable:next closure_body_length
        let additionalPropertiesRaw = arrangement.externalVariablesSet.compactMap { external in
            var properties: [SignalLiteral] = []
            for index in self.nodes.indices {
                let node = self.nodes[index]
                let instance = self.instances[index]
                let signals = arrangement.externals(instance: instance)
                guard let mapping = mappings[instance.name],
                    let localName = mapping[external],
                    let property = node.properties[localName],
                    let signal = signals[localName]
                else {
                    continue
                }
                switch node.type {
                case .read:
                    if signal.mode == .output {
                        properties.append(property)
                        continue
                    }
                case .write:
                    if signal.mode == .input {
                        properties.append(property)
                        continue
                    }
                }
                return (external, property)
            }
            guard properties.isEmpty else {
                guard Set(properties).count == 1 else {
                    fatalError("Conflicting properties for external \(external): \(properties)")
                }
                return (external, properties[0])
            }
            // print(
            //     "Failed to find any Machine that uses arrangement definition \(external). "
            //         + "Thus, pruning references to \(external) from the graph."
            // )
            return nil
        }
        let additionalProperties = Dictionary(uniqueKeysWithValues: additionalPropertiesRaw)
        return scopedProperties.merging(additionalProperties) { _, _ in
            fatalError("duplicate keys!")
        }
    }

    /// Derive the scoped properties for the combined node.
    func properties(excluding: [VariableName: Set<VariableName>] = [:]) -> [VariableName:
        SignalLiteral]
    {
        let nodes = zip(self.instanceNames, self.nodes)
        var properties: [VariableName: SignalLiteral] = [:]
        for (instanceName, node) in nodes {
            let excludeList = excluding[instanceName] ?? []
            for (propertyName, propertyValue) in node.properties where !excludeList.contains(propertyName) {
                // swiftlint:disable:next force_unwrapping
                let newName = VariableName(rawValue: "\(instanceName.rawValue)_\(propertyName.rawValue)")!
                properties[newName] = propertyValue
            }
            // swiftlint:disable:next force_unwrapping
            properties[VariableName(rawValue: "\(instanceName.rawValue)_executeOnEntry")!] = .boolean(
                value: node.executeOnEntry
            )
        }
        return properties
    }
}
