import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// A node scoped to an instance.
final class ScopedNode: Hashable, Equatable, Codable, Sendable, Comparable {
    /// The name of the instance the node belongs too.
    let instance: MachineInstance

    /// The node itself.
    let node: Node

    /// The name of the instance.
    var instanceName: VariableName {
        self.instance.name
    }

    /// Property init.
    init(instance: MachineInstance, node: Node) {
        self.instance = instance
        self.node = node
    }

    /// Equality conformance.
    static func == (lhs: ScopedNode, rhs: ScopedNode) -> Bool {
        lhs.instance == rhs.instance && lhs.node == rhs.node
    }

    /// Comparable conformance.
    static func < (lhs: ScopedNode, rhs: ScopedNode) -> Bool {
        guard lhs.instanceName == rhs.instanceName else {
            return lhs.instanceName < rhs.instanceName
        }
        guard lhs.instance.type == rhs.instance.type else {
            return lhs.instance.type < rhs.instance.type
        }
        return lhs.node < rhs.node
    }

    /// Hashing function.
    func hash(into hasher: inout Hasher) {
        hasher.combine(instance)
        hasher.combine(node)
    }

    /// Checks whether another node as the same values for their external variables if they exist.
    func hasSameExternals(
        as other: ScopedNode,
        in arrangement: Arrangement
    )
        -> Bool
    {
        guard let reverseMapping = arrangement.reverseExternalMappings[self.instanceName],
            let otherMapping = arrangement.externalMappings[other.instanceName]
        else {
            return true
        }
        let properties = node.properties.lazy.filter { reverseMapping.keys.contains($0.key) }
        return properties.allSatisfy {
            guard let externalName = reverseMapping[$0.key], let localName = otherMapping[externalName] else {
                return true
            }
            return $0.value == other.node.properties[localName]
        }
    }
}
