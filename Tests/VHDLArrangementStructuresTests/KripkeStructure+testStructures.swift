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
        let allNodes = initialStates + initialWrites + pingReads + pingWrites + pongReads + pongWrites
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

    /// The QuickTimer structure.
    static let quickTimer: KripkeStructure = {
        let initialStates = [
            Node(
                type: .read,
                currentState: .initial,
                executeOnEntry: true,
                nextState: .initial,
                properties: [.pulse: .bit(value: .low)]
            )
        ]
        let initialWrites = [
            Node(
                type: .write,
                currentState: .initial,
                executeOnEntry: true,
                nextState: .sendPulse,
                properties: [.pulse: .bit(value: .low)]
            )
        ]
        let sendPulseReads = [
            Node(
                type: .read,
                currentState: .sendPulse,
                executeOnEntry: true,
                nextState: .sendPulse,
                properties: [.pulse: .bit(value: .low)]
            )
        ]
        let sendPulseWrites = [
            Node(
                type: .write,
                currentState: .sendPulse,
                executeOnEntry: true,
                nextState: .clearPulse,
                properties: [.pulse: .bit(value: .high)]
            )
        ]
        let clearPulseReads = [
            Node(
                type: .read,
                currentState: .clearPulse,
                executeOnEntry: true,
                nextState: .clearPulse,
                properties: [.pulse: .bit(value: .high)]
            )
        ]
        let clearPulseWrites = [
            Node(
                type: .write,
                currentState: .clearPulse,
                executeOnEntry: true,
                nextState: .sendPulse,
                properties: [.pulse: .bit(value: .low)]
            )
        ]
        let edges: [Node: [Edge]] = [
            initialStates[0]: [Edge(target: initialWrites[0], cost: .readCost)],
            initialWrites[0]: [Edge(target: sendPulseReads[0], cost: .writeCost)],
            sendPulseReads[0]: [Edge(target: sendPulseWrites[0], cost: .readCost)],
            sendPulseWrites[0]: [Edge(target: clearPulseReads[0], cost: .writeCost)],
            clearPulseReads[0]: [Edge(target: clearPulseWrites[0], cost: .readCost)],
            clearPulseWrites[0]: [Edge(target: sendPulseReads[0], cost: .writeCost)],
        ]
        let allNodes =
            initialStates + initialWrites + sendPulseReads + sendPulseWrites + clearPulseReads
            + clearPulseWrites
        return KripkeStructure(nodes: allNodes, edges: edges, initialStates: Set(initialStates))
    }()

    // swiftlint:disable force_unwrapping

    /// The combined structure between the Ping Pong and Quick timer kripke structures.
    static let combinedStructure: KripkeStructure = {
        let initialStates = [
            Node(
                type: .read,
                currentState: VariableName(rawValue: "M0_Initial__M2_Initial")!,
                executeOnEntry: true,
                nextState: VariableName(rawValue: "M0_Initial__M2_Initial")!,
                properties: [
                    .extY: .bit(value: .low),
                    .x: .bit(value: .low),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let initialWrites = [
            Node(
                type: .write,
                currentState: VariableName(rawValue: "M0_Initial__M2_Initial")!,
                executeOnEntry: true,
                nextState: VariableName(rawValue: "M0_Ping__M2_SendPulse")!,
                properties: [
                    .extY: .bit(value: .low),
                    .x: .bit(value: .low),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pingSendPulseReads = [
            Node(
                type: .read,
                currentState: VariableName(rawValue: "M0_Ping__M2_SendPulse")!,
                executeOnEntry: true,
                nextState: VariableName(rawValue: "M0_Ping__M2_SendPulse")!,
                properties: [
                    .extY: .bit(value: .low),
                    .x: .bit(value: .low),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pingSendPulseWrites = [
            Node(
                type: .write,
                currentState: VariableName(rawValue: "M0_Ping__M2_SendPulse")!,
                executeOnEntry: false,
                nextState: VariableName(rawValue: "M0_Ping__M2_ClearPulse")!,
                properties: [
                    .extY: .bit(value: .low),
                    .x: .bit(value: .high),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: false),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pingClearPulseReads = [
            Node(
                type: .read,
                currentState: VariableName(rawValue: "M0_Ping__M2_ClearPulse")!,
                executeOnEntry: false,
                nextState: VariableName(rawValue: "M0_Ping__M2_ClearPulse")!,
                properties: [
                    .extY: .bit(value: .low),
                    .x: .bit(value: .high),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: false),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pingClearPulseWrites = [
            Node(
                type: .write,
                currentState: VariableName(rawValue: "M0_Ping__M2_ClearPulse")!,
                executeOnEntry: true,
                nextState: VariableName(rawValue: "M0_Pong__M2_SendPulse")!,
                properties: [
                    .extY: .bit(value: .high),
                    .x: .bit(value: .low),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pongSendPulseReads = [
            Node(
                type: .read,
                currentState: VariableName(rawValue: "M0_Pong__M2_SendPulse")!,
                executeOnEntry: true,
                nextState: VariableName(rawValue: "M0_Pong__M2_SendPulse")!,
                properties: [
                    .extY: .bit(value: .high),
                    .x: .bit(value: .low),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pongSendPulseWrites = [
            Node(
                type: .write,
                currentState: VariableName(rawValue: "M0_Pong__M2_SendPulse")!,
                executeOnEntry: false,
                nextState: VariableName(rawValue: "M0_Pong__M2_ClearPulse")!,
                properties: [
                    .extY: .bit(value: .high),
                    .x: .bit(value: .high),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: false),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pongClearPulseReads = [
            Node(
                type: .read,
                currentState: VariableName(rawValue: "M0_Pong__M2_ClearPulse")!,
                executeOnEntry: false,
                nextState: VariableName(rawValue: "M0_Pong__M2_SendPulse")!,
                properties: [
                    .extY: .bit(value: .high),
                    .x: .bit(value: .high),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: false),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let pongClearPulseWrites = [
            Node(
                type: .write,
                currentState: VariableName(rawValue: "M0_Pong__M2_ClearPulse")!,
                executeOnEntry: false,
                nextState: VariableName(rawValue: "M0_Ping__M2_SendPulse")!,
                properties: [
                    .extY: .bit(value: .low),
                    .x: .bit(value: .low),
                    VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: false),
                    VariableName(rawValue: "M2_executeOnEntry")!: .boolean(value: true),
                ]
            )
        ]
        let edges: [Node: [Edge]] = [
            initialStates[0]: [Edge(target: initialWrites[0], cost: .readCost)],
            initialWrites[0]: [Edge(target: pingSendPulseReads[0], cost: .writeCost)],
            pingSendPulseReads[0]: [Edge(target: pingSendPulseWrites[0], cost: .readCost)],
            pingSendPulseWrites[0]: [Edge(target: pingClearPulseReads[0], cost: .writeCost)],
            pingClearPulseReads[0]: [Edge(target: pingClearPulseWrites[0], cost: .readCost)],
            pingClearPulseWrites[0]: [Edge(target: pongSendPulseReads[0], cost: .writeCost)],
            pongSendPulseReads[0]: [Edge(target: pongSendPulseWrites[0], cost: .readCost)],
            pongSendPulseWrites[0]: [Edge(target: pongClearPulseReads[0], cost: .writeCost)],
            pongClearPulseReads[0]: [Edge(target: pongClearPulseWrites[0], cost: .readCost)],
            pongClearPulseWrites[0]: [Edge(target: pingSendPulseReads[0], cost: .writeCost)],
        ]
        let allNodes =
            initialStates + initialWrites + pingSendPulseReads + pingSendPulseWrites + pingClearPulseReads
            + pingClearPulseWrites + pongSendPulseReads + pongSendPulseWrites + pongClearPulseReads
            + pongClearPulseWrites
        return KripkeStructure(nodes: allNodes, edges: edges, initialStates: Set(initialStates))
    }()

    // swiftlint:enable force_unwrapping
    // swiftlint:enable closure_body_length

}

/// Add common costs.
extension Cost {
    /// The cost of a read -> write edge.
    static let readCost = Cost(time: ScientificQuantity(coefficient: 80, exponent: -9), energy: .zero)

    /// The cost of a write -> read edge.
    static let writeCost = Cost(time: ScientificQuantity(coefficient: 20, exponent: -9), energy: .zero)
}
