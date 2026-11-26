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
        let originalStructure = KripkeStructure.pingPongSingle
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

    /// Test that a writer can change a shared signal while another machine retains its input.
    @Test("Shared output changes retain their incoming edge.")
    func testSharedOutputChange() async throws {
        let arrangement = Arrangement.pingPongQuickTimerArrangement
        let pingPong = KripkeStructure.pingPong
        let quickTimer = KripkeStructure.quickTimer
        let instances: [MachineInstance] = [.pingPong(), .quickTimer()]
        let source = Node(
            node: CombinedNode(nodes: [pingPong.nodes[4], quickTimer.nodes[2]], instances: instances),
            arrangement: arrangement
        )
        let target = Node(
            node: CombinedNode(nodes: [pingPong.nodes[8], quickTimer.nodes[3]], instances: instances),
            arrangement: arrangement
        )
        let structure = await KripkeStructure(
            arrangement: arrangement,
            kripkeStructures: [.pingPong(): pingPong, .quickTimer(): quickTimer]
        )
        let edges = try #require(structure.edges[source])
        #expect(edges.contains { $0.target == target })
        #expect(structure.nodes.contains(target))
        #expect(source.properties[.x] == .bit(value: .low))
        #expect(target.properties[.x] == .bit(value: .high))
    }

    /// Test duplicate edges do not repeatedly schedule cyclic jobs.
    @Test("Duplicate cyclic edges preserve edges without repeating jobs.")
    func testDuplicateCyclicEdges() async {
        let first = KripkeStructure.pingPong.nodes[0]
        let second = KripkeStructure.pingPong.nodes[2]
        let forward = Edge(target: second, cost: .readCost)
        let backward = Edge(target: first, cost: .writeCost)
        let structure = KripkeStructure(
            nodes: [first, second],
            edges: [first: [forward, forward], second: [backward, backward]],
            initialStates: [first]
        )
        let processor = JobProcessor()
        let result = await processor.combineKripkeStructures(
            arrangement: .pingPongArrangement,
            kripkeStructures: [.pingPong(): structure]
        )
        let processedCount = await processor.processedJobs.count
        #expect(processedCount == 2)
        #expect(result.nodes.count == 2)
        #expect(result.edges[first.toPingPongNode]?.count == 2)
        #expect(result.edges[second.toPingPongNode]?.count == 2)
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
            currentState: VariableName(rawValue: "\(self.currentState)")!,
            executeOnEntry: self.executeOnEntry,
            nextState: VariableName(rawValue: "\(self.nextState)")!,
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
