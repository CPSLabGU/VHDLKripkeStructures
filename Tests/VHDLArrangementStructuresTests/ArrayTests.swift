import Testing
@testable import VHDLArrangementStructures
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Tests for array extensions.
@Suite
struct ArrayTests {

    /// The nodes in all kripke structures.
    let nodes: [[ScopedNode]] = [
        [
            ScopedNode(instance: .pingPong(), node: .pingReadNode),
            ScopedNode(instance: .pingPong(), node: .pingWriteNode),
            ScopedNode(instance: .pingPong(), node: .pingReadNodeNoPulse),
            ScopedNode(instance: .pingPong(), node: .pingWriteNodeNoPulse),
        ],
        [
            ScopedNode(instance: .timer(), node: .timerReadNode),
            ScopedNode(instance: .timer(), node: .timerWriteNode),
            ScopedNode(instance: .timer(), node: .timerReadNodePulse),
            ScopedNode(instance: .timer(), node: .timerWriteNodePulse),
            ScopedNode(instance: .timer(), node: .timerWriteNodeSetPulse),
        ],
    ]

    /// The instances.
    let instances: [MachineInstance] = [.pingPong(), .timer()]

    /// Test kripke folding.
    @Test("Can fold kripke nodes into a single structure.")
    func testKripkeFolding() async {
        let expected = [
            CombinedNode(nodes: [.pingReadNode, .timerReadNode], instances: instances),
            CombinedNode(nodes: [.pingReadNode, .timerReadNodePulse], instances: instances),
            CombinedNode(nodes: [.pingWriteNode, .timerWriteNode], instances: instances),
            CombinedNode(nodes: [.pingWriteNode, .timerWriteNodePulse], instances: instances),
            CombinedNode(nodes: [.pingWriteNode, .timerWriteNodeSetPulse], instances: instances),
            CombinedNode(nodes: [.pingReadNodeNoPulse, .timerReadNode], instances: instances),
            CombinedNode(nodes: [.pingReadNodeNoPulse, .timerReadNodePulse], instances: instances),
            CombinedNode(nodes: [.pingWriteNodeNoPulse, .timerWriteNode], instances: instances),
            CombinedNode(nodes: [.pingWriteNodeNoPulse, .timerWriteNodePulse], instances: instances),
            CombinedNode(nodes: [.pingWriteNodeNoPulse, .timerWriteNodeSetPulse], instances: instances),
        ]
        let actual = await [CombinedNode](nodes: self.nodes, arrangement: .testArrangement, currentState: [:])
        #expect(actual == expected)
    }

    /// Test filtering mapped global values in each machine.
    @Test("Global state filters mapped properties in each machine.")
    func testGlobalStateFiltering() async {
        let actual = await [CombinedNode](
            nodes: nodes,
            arrangement: .testArrangement,
            currentState: [.x: .bit(value: .high), .extY: .bit(value: .low)]
        )
        #expect(
            actual == [
                CombinedNode(nodes: [.pingReadNode, .timerReadNodePulse], instances: instances)
            ]
        )

        let noMatches = await [CombinedNode](
            nodes: [[nodes[0][0]], [nodes[1][0]]],
            arrangement: .testArrangement,
            currentState: [.x: .bit(value: .high)]
        )
        #expect(noMatches.isEmpty)
    }

    /// Test grouping across three machines when a property is absent.
    @Test("Missing properties do not constrain groups across three machines.")
    func testMissingPropertiesAcrossMachines() async {
        let missingProperty = Node(
            type: .read,
            currentState: .ping,
            executeOnEntry: true,
            nextState: .ping,
            properties: [:]
        )
        let quickTimer = MachineInstance.quickTimer()
        let actual = await [CombinedNode](
            nodes: [
                [ScopedNode(instance: .pingPong(), node: missingProperty)],
                [
                    ScopedNode(instance: .quickTimer(), node: .timerReadNodePulse),
                    ScopedNode(instance: .quickTimer(), node: .timerReadNode),
                ],
                [ScopedNode(instance: .timer(), node: .timerReadNodePulse)],
            ],
            arrangement: .pingPongQuickTimerArrangement,
            currentState: [.x: .bit(value: .high)]
        )
        #expect(
            actual == [
                CombinedNode(
                    nodes: [missingProperty, .timerReadNodePulse, .timerReadNodePulse],
                    instances: [.pingPong(), quickTimer, .timer()]
                )
            ]
        )
    }

    /// Test filtering global values for a single machine.
    @Test("Global state also filters a single machine.")
    func testSingleMachineFiltering() async {
        let actual = await [CombinedNode](
            nodes: [nodes[0]],
            arrangement: .testArrangement,
            currentState: [.x: .bit(value: .low)]
        )
        #expect(
            actual == [
                CombinedNode(scopedNodes: [nodes[0][2]]),
                CombinedNode(scopedNodes: [nodes[0][3]]),
            ]
        )
    }

    /// Test cartesian product.
    @Test("Test cartesian product functionality.")
    func testCartesianProduct() {
        let original = [[1, 2], [3, 4]]
        let expected = [[1, 3], [1, 4], [2, 3], [2, 4]]
        #expect(original.cartesianProduct == expected)
    }

}
