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
    func testSingleMachineArrangement() {
        let originalStructure = KripkeStructure.pingPong
        let structure = KripkeStructure(
            arrangement: .pingPongArrangement,
            kripkeStructures: [.pingPong(): originalStructure]
        )
        let nodes = originalStructure.nodes.map(\.toPingPongNode)
        let initialStates = Set(originalStructure.initialStates.map(\.toPingPongNode))
        let edges = originalStructure.edges.map {
            ($0.key.toPingPongNode, $0.value.map(\.toPingPongEdge))
        }
        let expected = KripkeStructure(
            nodes: nodes,
            edges: Dictionary(uniqueKeysWithValues: edges),
            initialStates: initialStates
        )
        let expectedNodes = Set(expected.nodes)
        let additionalNodes = structure.nodes.filter { !expectedNodes.contains($0) }
        print(additionalNodes)
        // #expect(Set(structure.nodes) == Set(expected.nodes))
        #expect(structure.edges == expected.edges)
        #expect(structure.initialStates == expected.initialStates)
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
