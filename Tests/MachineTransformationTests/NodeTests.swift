@testable import MachineTransformations
import Testing
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Tests for `Node` extensions.
@Suite
struct NodeTests {
    /// A node for testing.
    let node = CombinedNode(nodes: [.pingReadNode, .timerReadNodePulse], instances: [.pingPong(), .timer()])

    /// Init tests without arrangement.
    @Test("Test init without arrangement.")
    func testInitWithoutArrangement() {
        let node = Node(node: self.node)
        #expect(node.type == .read)
        #expect(node.currentState == VariableName(rawValue: "M0_Ping__M1_CountTime"))
        #expect(!node.executeOnEntry)
        #expect(node.nextState == VariableName(rawValue: "M0_Ping__M1_CountTime"))
        // swiftlint:disable force_unwrapping
        let expected: [VariableName: SignalLiteral] = [
            VariableName(rawValue: "M0_y")!: .bit(value: .low),
            VariableName(rawValue: "M0_timerPulse")!: .bit(value: .high),
            VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
            VariableName(rawValue: "M1_pulse")!: .bit(value: .high),
            VariableName(rawValue: "M1_counter")!: .integer(value: 0),
            VariableName(rawValue: "M1_executeOnEntry")!: .boolean(value: false),
        ]
        // swiftlint:enable force_unwrapping
        #expect(node.properties == expected)
    }

    /// Init tests with arrangement.
    @Test("Test init with arrangement.")
    func testInitWithArrangement() {
        let node = Node(node: self.node, arrangement: .testArrangement)
        #expect(node.type == .read)
        #expect(node.currentState == VariableName(rawValue: "M0_Ping__M1_CountTime"))
        #expect(!node.executeOnEntry)
        #expect(node.nextState == VariableName(rawValue: "M0_Ping__M1_CountTime"))
        // swiftlint:disable force_unwrapping
        let expected: [VariableName: SignalLiteral] = [
            .extY: .bit(value: .low),
            .x: .bit(value: .high),
            VariableName(rawValue: "M0_executeOnEntry")!: .boolean(value: true),
            VariableName(rawValue: "M1_counter")!: .integer(value: 0),
            VariableName(rawValue: "M1_executeOnEntry")!: .boolean(value: false),
        ]
        // swiftlint:enable force_unwrapping
        #expect(node.properties == expected)
    }
}
