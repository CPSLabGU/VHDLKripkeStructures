@testable import MachineTransformations
import Testing
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
    func testKripkeFolding() {
        let expected = [
            CombinedNode(nodes: [.pingReadNode, .timerReadNodePulse], instances: instances),
            CombinedNode(nodes: [.pingWriteNode, .timerWriteNodeSetPulse], instances: instances),
            CombinedNode(nodes: [.pingReadNodeNoPulse, .timerReadNode], instances: instances),
            CombinedNode(nodes: [.pingWriteNodeNoPulse, .timerWriteNode], instances: instances),
            CombinedNode(nodes: [.pingWriteNodeNoPulse, .timerWriteNodePulse], instances: instances),
        ]
        let actual = [CombinedNode](nodes: self.nodes, arrangement: .testArrangement)
        #expect(actual == expected)
    }

}
