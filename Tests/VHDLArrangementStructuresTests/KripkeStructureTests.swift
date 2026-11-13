import Testing
@testable import VHDLArrangementStructures
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Suite for kripke structure testing.
@Suite
struct KripkeStructureTests {

    /// Test kripke structure is created for simple arrangements.
    @Test("Kripke structures can be created for arrangements with a single machine.")
    func testSingleMachineArrangement() async {
        let originalStructure = KripkeStructure.pingPong
        let expected = await KripkeStructure(
            arrangement: .pingPongArrangement,
            kripkeStructures: [.pingPong(): originalStructure]
        )
        let nodes = originalStructure.nodes.map(\.toPingPongNode)
        let initialStates = Set(originalStructure.initialStates.map(\.toPingPongNode))
        let edges = originalStructure.edges.map {
            ($0.key.toPingPongNode, $0.value.map(\.toPingPongEdge))
        }
        let actual = KripkeStructure(
            nodes: nodes,
            edges: Dictionary(uniqueKeysWithValues: edges),
            initialStates: initialStates
        )
        #expect(expected == actual)
    }

    /// Test kripke structure with multiple machines.
    @Test("Kripke structures can be created for arrangements with multiple machines.")
    func testMultipleMachineArrangement() async {
        let actual = await KripkeStructure(
            arrangement: .pingPongQuickTimerArrangement,
            kripkeStructures: [.pingPong(): .pingPong, .quickTimer(): .quickTimer]
        )
        let expected = KripkeStructure.combinedStructure
        #expect(actual == expected)
    }

    /// Test concurrent branches that converge and form cycles.
    @Test("Concurrent branches can converge and form cycles.")
    func testConvergingCycles() async {
        let first = KripkeStructure.pingPong.nodes[0]
        let second = KripkeStructure.pingPong.nodes[1]
        let joined = KripkeStructure.pingPong.nodes[2]
        let edges: [Node: [Edge]] = [
            first: [Edge(target: joined, cost: .readCost)],
            second: [Edge(target: joined, cost: .readCost)],
            joined: [
                Edge(target: first, cost: .writeCost),
                Edge(target: second, cost: .writeCost),
            ],
        ]
        let structure = KripkeStructure(
            nodes: [first, second, joined],
            edges: edges,
            initialStates: [first, second]
        )
        let actual = await KripkeStructure(
            arrangement: .pingPongArrangement,
            kripkeStructures: [.pingPong(): structure]
        )
        let expected = KripkeStructure(
            nodes: structure.nodes.map(\.toPingPongNode),
            edges: Dictionary(
                uniqueKeysWithValues: edges.map {
                    ($0.key.toPingPongNode, $0.value.map(\.toPingPongEdge))
                }
            ),
            initialStates: Set(structure.initialStates.map(\.toPingPongNode))
        )
        #expect(actual == expected)
    }
}

/// Add helper to convert a node to a ping pong node.
extension Node {
    /// Convert to a ping pong node.
    fileprivate var toPingPongNode: Node {
        let rawProperties = self.properties.map {
            switch $0.key {
            case .y:
                return (VariableName.extY, $0.value)
            case .timerPulse:
                return (VariableName.x, $0.value)
            default:
                return ($0.key, $0.value)
            }
        }
        // swiftlint:disable force_unwrapping
        return Node(
            type: self.type,
            currentState: VariableName(rawValue: "M0_\(self.currentState)")!,
            executeOnEntry: self.executeOnEntry,
            nextState: VariableName(rawValue: "M0_\(self.nextState)")!,
            properties: Dictionary(
                uniqueKeysWithValues: rawProperties + [
                    (VariableName(rawValue: "M0_executeOnEntry")!, .boolean(value: self.executeOnEntry))
                ]
            )
        )
        // swiftlint:enable force_unwrapping
    }
}

/// Add helpers.
extension Edge {
    /// Convert to a ping pong edge.
    fileprivate var toPingPongEdge: Edge {
        Edge(target: self.target.toPingPongNode, cost: self.cost)
    }
}
