@testable import MachineTransformations
import Testing
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Tests for ScopedNode type.
@Suite
struct ScopedNodeTests {

    /// The underlying node.
    let rawNode = Node(
        type: .read,
        currentState: .ping,
        executeOnEntry: true,
        nextState: .pong,
        properties: [.y: .bit(value: .low)]
    )

    /// The underlying instance.
    let instance = MachineInstance.pingPong(name: .m0)

    /// The scoped node under test.
    var node: ScopedNode

    /// Set the node under test.
    init() {
        self.node = ScopedNode(instance: instance, node: rawNode)
    }

    /// Test initialiser.
    @Test("ScopedNode initialises stored properties correctly.")
    func testInitialiser() {
        #expect(node.instance == instance)
        #expect(node.node == rawNode)
    }

    /// Instance name is derived correctly.
    @Test("Instance name is derived correctly.")
    func testInstanceName() {
        #expect(node.instanceName == instance.name)
    }

    /// Equality works correctly.
    @Test("Equality works correctly.")
    func testEquality() {
        let sameNode = ScopedNode(instance: instance, node: rawNode)
        #expect(node == sameNode)
        let differentNode = ScopedNode(
            instance: instance,
            node: Node(
                type: .write,
                currentState: .ping,
                executeOnEntry: true,
                nextState: .pong,
                properties: [.y: .bit(value: .high)]
            )
        )
        #expect(node != differentNode)
        let differentInstanceNode = ScopedNode(instance: MachineInstance.pingPong(name: .x), node: rawNode)
        #expect(node != differentInstanceNode)
    }

    /// Test hashing.
    @Test("Hashing works correctly.")
    func testHashing() {
        let nodeSet: Set<ScopedNode> = [node]
        #expect(nodeSet.contains(node))
        let sameNode = ScopedNode(instance: instance, node: rawNode)
        #expect(nodeSet.contains(sameNode))
        #expect(nodeSet.contains(node))
        #expect(nodeSet.count == 1)
        let differentNode = ScopedNode(
            instance: instance,
            node: Node(
                type: .write,
                currentState: .ping,
                executeOnEntry: true,
                nextState: .pong,
                properties: [.y: .bit(value: .high)]
            )
        )
        #expect(!nodeSet.contains(differentNode))
        let differentInstanceNode = ScopedNode(instance: MachineInstance.pingPong(name: .x), node: rawNode)
        #expect(!nodeSet.contains(differentInstanceNode))
    }

}
