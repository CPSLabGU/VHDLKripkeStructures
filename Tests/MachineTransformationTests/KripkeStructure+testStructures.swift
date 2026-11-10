import VHDLKripkeStructures
import VHDLParsing

/// Add test structures.
extension KripkeStructure {

    // swiftlint:disable closure_body_length

    /// The PingPong structure.
    static let pingPong: KripkeStructure = {
        let initialStates = [
            Node(
                type: .read,
                currentState: .initial,
                executeOnEntry: true,
                nextState: .initial,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .read,
                currentState: .initial,
                executeOnEntry: true,
                nextState: .initial,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
            ),
        ]
        let initialWrites = [
            Node(
                type: .write,
                currentState: .initial,
                executeOnEntry: true,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .write,
                currentState: .initial,
                executeOnEntry: true,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
            ),
        ]
        let pingReads = [
            Node(
                type: .read,
                currentState: .ping,
                executeOnEntry: true,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .read,
                currentState: .ping,
                executeOnEntry: true,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
            ),
            Node(
                type: .read,
                currentState: .ping,
                executeOnEntry: false,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .read,
                currentState: .ping,
                executeOnEntry: false,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
            ),
        ]
        let pingWrites = [
            Node(
                type: .write,
                currentState: .ping,
                executeOnEntry: false,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .write,
                currentState: .ping,
                executeOnEntry: true,
                nextState: .pong,
                properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .high)]
            ),
        ]
        let pongReads = [
            Node(
                type: .read,
                currentState: .pong,
                executeOnEntry: true,
                nextState: .pong,
                properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .read,
                currentState: .pong,
                executeOnEntry: true,
                nextState: .pong,
                properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .high)]
            ),
            Node(
                type: .read,
                currentState: .pong,
                executeOnEntry: false,
                nextState: .pong,
                properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .read,
                currentState: .pong,
                executeOnEntry: false,
                nextState: .pong,
                properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .high)]
            ),
        ]
        let pongWrites = [
            Node(
                type: .write,
                currentState: .pong,
                executeOnEntry: false,
                nextState: .pong,
                properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .low)]
            ),
            Node(
                type: .write,
                currentState: .pong,
                executeOnEntry: true,
                nextState: .ping,
                properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
            ),
        ]
        let allNodes = initialStates + pongReads + pongWrites
        let edges: [Node: [Edge]] = [
            initialStates[0]: [
                Edge(target: initialWrites[0], cost: .readCost)
            ],
            initialStates[1]: [
                Edge(target: initialWrites[1], cost: .readCost)
            ],
            initialWrites[0]: [
                Edge(target: pingReads[0], cost: .writeCost),
                Edge(target: pingReads[1], cost: .writeCost),
            ],
            initialWrites[1]: [
                Edge(target: pingReads[0], cost: .writeCost),
                Edge(target: pingReads[1], cost: .writeCost),
            ],
            pingReads[0]: [
                Edge(target: pingWrites[0], cost: .readCost)
            ],
            pingReads[1]: [
                Edge(target: pingWrites[1], cost: .readCost)
            ],
            pingReads[2]: [
                Edge(target: pingWrites[0], cost: .readCost)
            ],
            pingReads[3]: [
                Edge(target: pingWrites[1], cost: .readCost)
            ],
            pingWrites[0]: [
                Edge(target: pingReads[2], cost: .writeCost),
                Edge(target: pingReads[3], cost: .writeCost),
            ],
            pingWrites[1]: [
                Edge(target: pongReads[0], cost: .writeCost),
                Edge(target: pongReads[1], cost: .writeCost),
            ],
            pongReads[0]: [
                Edge(target: pongWrites[0], cost: .readCost)
            ],
            pongReads[1]: [
                Edge(target: pongWrites[1], cost: .readCost)
            ],
            pongReads[2]: [
                Edge(target: pongWrites[0], cost: .readCost)
            ],
            pongReads[3]: [
                Edge(target: pongWrites[1], cost: .readCost)
            ],
            pongWrites[0]: [
                Edge(target: pongReads[2], cost: .writeCost),
                Edge(target: pongReads[3], cost: .writeCost),
            ],
            pongWrites[1]: [
                Edge(target: pingReads[0], cost: .writeCost),
                Edge(target: pingReads[1], cost: .writeCost),
            ],
        ]
        return KripkeStructure(nodes: allNodes, edges: edges, initialStates: Set(initialStates))
    }()

    // swiftlint:enable closure_body_length

}

/// Add common costs.
extension Cost {
    /// The cost of a read -> write edge.
    static let readCost = Cost(time: ScientificQuantity(coefficient: 80, exponent: -9), energy: .zero)

    /// The cost of a write -> read edge.
    static let writeCost = Cost(time: ScientificQuantity(coefficient: 20, exponent: -9), energy: .zero)
}
