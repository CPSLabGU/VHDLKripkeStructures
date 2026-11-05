import VHDLKripkeStructures
import VHDLParsing

/// A node scoped to an instance.
final class ScopedNode: Hashable, Equatable, Codable, Sendable {
    /// The name of the instance the node belongs too.
    let instanceName: VariableName

    /// The node itself.
    let node: Node

    /// Property init.
    init(instanceName: VariableName, node: Node) {
        self.instanceName = instanceName
        self.node = node
    }

    /// Equality conformance.
    static func == (lhs: ScopedNode, rhs: ScopedNode) -> Bool {
        lhs.instanceName == rhs.instanceName && lhs.node == rhs.node
    }

    /// Hashing function.
    func hash(into hasher: inout Hasher) {
        hasher.combine(instanceName)
        hasher.combine(node)
    }

    /// Checks whether another node as the same values for their external variables if they exist.
    func hasSameExternals(
        other: ScopedNode,
        externalMappings: [VariableName: [VariableName: VariableName]],
        reverseMappings: [VariableName: [VariableName: VariableName]]
    )
        -> Bool
    {
        guard let reverseMapping = reverseMappings[self.instanceName],
            let otherMapping = externalMappings[other.instanceName]
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
