import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

// swiftlint:disable type_name

/// The jobs that need to be processed when creating an arrangements Kripke structure.
final class Job: Equatable, Hashable, Codable, Sendable {

    /// The underlying node.
    let node: CombinedNode

    /// The arrangement this job belongs to.
    let arrangement: Arrangement

    /// The properties of the node scoped to the arrangement.
    var properties: [VariableName: SignalLiteral] {
        self.node.properties(arrangement: self.arrangement)
    }

    /// The global variables in this job.
    var globalProperties: [VariableName: SignalLiteral] {
        let globals = self.arrangement.globalVariables
        return Dictionary(uniqueKeysWithValues: self.properties.filter { globals.contains($0.key) })
    }

    /// The current state of the node to process.
    var currentState: VariableName {
        node.name
    }

    /// The next state of the node to process.
    var nextState: VariableName {
        node.nextState
    }

    /// Whether to execute the node on entry.
    var executeOnEntry: Bool {
        node.executeOnEntry
    }

    /// The type of the node.
    var type: NodeType {
        node.type
    }

    /// Creates a job from a combined node and an arrangement.
    init(
        node: CombinedNode,
        arrangement: Arrangement
    ) {
        self.node = node
        self.arrangement = arrangement
    }

    /// Equality operation.
    static func == (lhs: Job, rhs: Job) -> Bool {
        lhs.currentState == rhs.currentState && lhs.nextState == rhs.nextState
            && lhs.executeOnEntry == rhs.executeOnEntry && lhs.type == rhs.type
            && lhs.properties == rhs.properties
    }

    /// Hashing function.
    func hash(into hasher: inout Hasher) {
        hasher.combine(currentState)
        hasher.combine(nextState)
        hasher.combine(executeOnEntry)
        hasher.combine(type)
        hasher.combine(properties)
    }

}

// swiftlint:enable type_name
