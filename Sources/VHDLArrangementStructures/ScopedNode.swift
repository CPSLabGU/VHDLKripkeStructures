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
        in arrangement: Arrangement,
        globalState: [VariableName: SignalLiteral]
    ) -> Bool {
        switch self.node.type {
        case .write:
            return hasSameExternalsWrite(other: other, arrangement: arrangement, globalState: globalState)
        case .read:
            return hasSameExternalsRead(other: other, arrangement: arrangement, globalState: globalState)
        }
    }

    /// Check same externals for read node.
    private func hasSameExternalsRead(
        other: ScopedNode,
        arrangement: Arrangement,
        globalState: [VariableName: SignalLiteral]
    ) -> Bool {
        guard let reverseMapping = arrangement.reverseExternalMappings[self.instanceName],
            let otherMapping = arrangement.externalMappings[other.instanceName]
        else {
            return true
        }
        let signals = arrangement.externals(instance: other.instance)
        let properties = node.properties.lazy.filter { reverseMapping.keys.contains($0.key) }
        return properties.allSatisfy { property in
            guard let externalName = reverseMapping[property.key], let localName = otherMapping[externalName]
            else {
                return true
            }
            guard let externalSignal = signals[localName] else {
                fatalError("External signal \(localName) not found in machine \(other.instanceName)")
            }
            switch externalSignal.mode {
            case .output:
                guard let previousValue = globalState[externalName] else {
                    return true
                }
                return property.value == previousValue
            default:
                return property.value == other.node.properties[localName]
            }
        }
    }

    /// Check same externals for write node.
    private func hasSameExternalsWrite(
        other: ScopedNode,
        arrangement: Arrangement,
        globalState: [VariableName: SignalLiteral]
    ) -> Bool {
        guard let reverseMapping = arrangement.reverseExternalMappings[self.instanceName],
            let otherMapping = arrangement.externalMappings[other.instanceName]
        else {
            return true
        }
        let signals = arrangement.externals(instance: self.instance)
        let properties = node.properties.lazy.filter { reverseMapping.keys.contains($0.key) }
        return properties.allSatisfy { property in
            guard let externalName = reverseMapping[property.key], let localName = otherMapping[externalName]
            else {
                return true
            }
            guard let externalSignal = signals[property.key] else {
                fatalError("External signal \(property.key) not found in machine \(self.instanceName)")
            }
            switch externalSignal.mode {
            case .input:
                guard let previousValue = globalState[externalName] else {
                    return true
                }
                return property.value == previousValue
            default:
                return property.value == other.node.properties[localName]
            }
        }
    }
}
