import Foundation
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Add arrangement Kripke structure creation.
extension KripkeStructure {

    // swiftlint:disable function_body_length

    /// Create a combined kripke structure from all machines in the arrangement.
    /// - Parameters:
    ///   - arrangement: The arrangement containing the machines.
    ///   - kripkeStructures: A dictionary mapping machine instances to their kripke structures.
    /// - Throws: An error if the kripke structure cannot be created.
    public convenience init(arrangement: Arrangement, kripkeStructures: [MachineInstance: KripkeStructure]) {
        let scopedNodes = arrangement.machines.keys.map { instance in
            guard let structure = kripkeStructures[instance] else {
                fatalError("Kripke structure not found for machine instance \(instance)")
            }
            return structure.initialStates.map { ScopedNode(instance: instance, node: $0) }
        }
        var jobs = [CombinedNode](nodes: scopedNodes, arrangement: arrangement)
        var processedJobs: Set<CombinedNode> = []
        let initialNodes = Set(jobs.map { Node(node: $0, arrangement: arrangement) })
        var nodes = initialNodes
        var allEdges: [Node: [Edge]] = [:]
        while let job = jobs.popLast() {
            guard !processedJobs.contains(job) else {
                continue
            }
            processedJobs.insert(job)
            let sourceNode = Node(node: job, arrangement: arrangement)
            nodes.insert(sourceNode)
            let kripkeStructures = job.instances.compactMap { kripkeStructures[$0] }
            guard kripkeStructures.count == job.instances.count else {
                fatalError("Kripke structures not found for all instances in the combined node")
            }
            let edges = kripkeStructures.indices.map {
                guard let edges = kripkeStructures[$0].edges[job.nodes[$0]] else {
                    fatalError(
                        "Edges not found for node \(job.nodes[$0]) in "
                            + "kripke structure \(kripkeStructures[$0])"
                    )
                }
                return edges
            }
            guard !edges.isEmpty, edges.allSatisfy({ !$0.isEmpty }),
                edges.allSatisfy({ edgeList in edgeList.allSatisfy { edgeList[0].cost == $0.cost } })
            else {
                fatalError("Edges are either empty or have inconsistent costs for combined node \(job)")
            }
            let cost = edges[0][0].cost
            let scopedNodes = edges.indices.map { index in
                edges[index]
                    .map {
                        ScopedNode(instance: job.instances[index], node: $0.target)
                    }
            }
            let nodes = [CombinedNode](nodes: scopedNodes, arrangement: arrangement)
            jobs.append(contentsOf: nodes)
            let newEdges = nodes.map {
                Edge(target: Node(node: $0, arrangement: arrangement), cost: cost)
            }
            guard allEdges[sourceNode] == nil else {
                fatalError("Edges for source node \(sourceNode) already exist")
            }
            allEdges[sourceNode] = newEdges
        }
        print("\(nodes.count) Nodes found!")
        print("\(allEdges.values.reduce(0) { $0 + $1.count }) Edges found!")
        self.init(
            nodes: Array(nodes),
            edges: allEdges,
            initialStates: initialNodes
        )
    }

    // swiftlint:enable function_body_length
}
