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
    func testKripkeFolding() {
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
        let actual = [CombinedNode](nodes: self.nodes, arrangement: .testArrangement)
        #expect(actual == expected)
    }

    /// Test cartesian product.
    @Test("Test cartesian product functionality.")
    func testCartesianProduct() {
        let original = [[1, 2], [3, 4]]
        let expected = [[1, 3], [1, 4], [2, 3], [2, 4]]
        #expect(original.cartesianProduct == expected)
    }

}
