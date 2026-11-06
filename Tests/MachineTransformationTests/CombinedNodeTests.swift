@testable import MachineTransformations
import Testing
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Tests for ``CombinedNode``.
@Suite
struct CombinedNodeTests {
    /// The nodes.
    let nodes: [Node] = [.pingReadNode, .timerReadNodePulse]

    /// The names of the instances.
    let instances: [MachineInstance] = [.pingPong(), .timer()]

    /// The node under test.
    var node: CombinedNode

    /// Initialise node.
    init() {
        self.node = CombinedNode(nodes: self.nodes, instances: self.instances)
    }

    /// Test names.
    @Test("Set properties correctly.")
    func testProperties() {
        #expect(node.nodes == self.nodes)
        #expect(node.instances == self.instances)
        #expect(node.instanceNames == [.m0, .m1])
        #expect(node.type == .read)
        #expect(!node.executeOnEntry)
    }

    /// Name is calculated correctly.
    @Test("Name is calculated correctly.")
    func testName() throws {
        let expected = try #require(VariableName(rawValue: "M0_Ping__M1_CountTime"))
        #expect(node.name == expected)
    }

    /// Next state is calculated correctly.
    @Test("Next state is calculated correctly.")
    func testNextState() throws {
        let expected = try #require(VariableName(rawValue: "M0_Pong__M1_CountTime"))
        #expect(node.nextState == expected)
    }

    /// Can create from scoped nodes.
    @Test("Can create combined node from scoped nodes.")
    func testScopedNodes() throws {
        let scopedNodes = [
            ScopedNode(instance: self.instances[0], node: self.nodes[0]),
            ScopedNode(instance: self.instances[1], node: self.nodes[1]),
        ]
        let combined = CombinedNode(scopedNodes: scopedNodes)
        #expect(combined == self.node)
    }
}
