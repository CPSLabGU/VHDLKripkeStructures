@testable import MachineTransformations
import Testing
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Tests for ScopedNode type.
@Suite
struct ScopedNodeTests {

    /// The underlying node.
    let readNode = Node(
        type: .read,
        currentState: .ping,
        executeOnEntry: true,
        nextState: .pong,
        properties: [.y: .bit(value: .low), .timerPulse: .bit(value: .high)]
    )

    /// The equivalent write node.
    let writeNode = Node(
        type: .write,
        currentState: .ping,
        executeOnEntry: true,
        nextState: .pong,
        properties: [.y: .bit(value: .high), .timerPulse: .bit(value: .high)]
    )

    /// The underlying instance.
    let instance = MachineInstance.pingPong(name: .m0)

    /// The scoped node under test.
    var node: ScopedNode

    /// Set the node under test.
    init() {
        self.node = ScopedNode(instance: instance, node: readNode)
    }

    /// Test initialiser.
    @Test("ScopedNode initialises stored properties correctly.")
    func testInitialiser() {
        #expect(node.instance == instance)
        #expect(node.node == readNode)
    }

    /// Instance name is derived correctly.
    @Test("Instance name is derived correctly.")
    func testInstanceName() {
        #expect(node.instanceName == instance.name)
    }

    /// Equality works correctly.
    @Test("Equality works correctly.")
    func testEquality() {
        let sameNode = ScopedNode(instance: instance, node: readNode)
        #expect(node == sameNode)
        let differentNode = ScopedNode(
            instance: instance,
            node: writeNode
        )
        #expect(node != differentNode)
        let differentInstanceNode = ScopedNode(instance: MachineInstance.pingPong(name: .x), node: readNode)
        #expect(node != differentInstanceNode)
    }

    /// Test hashing.
    @Test("Hashing works correctly.")
    func testHashing() {
        let nodeSet: Set<ScopedNode> = [node]
        #expect(nodeSet.contains(node))
        let sameNode = ScopedNode(instance: instance, node: readNode)
        #expect(nodeSet.contains(sameNode))
        #expect(nodeSet.contains(node))
        #expect(nodeSet.count == 1)
        let differentNode = ScopedNode(
            instance: instance,
            node: writeNode
        )
        #expect(!nodeSet.contains(differentNode))
        let differentInstanceNode = ScopedNode(instance: MachineInstance.pingPong(name: .x), node: readNode)
        #expect(!nodeSet.contains(differentInstanceNode))
    }

}
