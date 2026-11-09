import VHDLKripkeStructures
import VHDLParsing

/// Add test nodes.
extension Node {

    /// The pingPong read Node with pulse.
    static let pingReadNode = Node(
        type: .read,
        currentState: .ping,
        executeOnEntry: true,
        nextState: .ping,
        properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
    )

    /// The pingPong write Node with pulse.
    static let pingWriteNode = Node(
        type: .write,
        currentState: .ping,
        executeOnEntry: true,
        nextState: .pong,
        properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .high)]
    )

    /// Timer read node without pulse.
    static let timerReadNode = Node(
        type: .read,
        currentState: .countTime,
        executeOnEntry: false,
        nextState: .countTime,
        properties: [.pulse: .bit(value: .low), .counter: .integer(value: 27)]
    )

    /// Timer read node with pulse.
    static let timerReadNodePulse = Node(
        type: .read,
        currentState: .countTime,
        executeOnEntry: false,
        nextState: .countTime,
        properties: [.pulse: .bit(value: .high), .counter: .integer(value: 0)]
    )

}
