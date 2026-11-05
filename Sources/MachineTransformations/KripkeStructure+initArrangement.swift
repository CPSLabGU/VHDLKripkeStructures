import Foundation
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// Add arrangement Kripke structure creation.
extension KripkeStructure {

    /// Create a combined kripke structure from all machines in the arrangement.
    /// - Parameters:
    ///   - arrangement: The arrangement containing the machines.
    ///   - kripkeStructures: A dictionary mapping machine instances to their kripke structures.
    /// - Throws: An error if the kripke structure cannot be created.
    public convenience init(arrangement: Arrangement, kripkeStructures: [MachineInstance: KripkeStructure])
        throws
    {
        let scopedNodes = arrangement.machines.keys.map { instance in
            guard let structure = kripkeStructures[instance] else {
                fatalError("Kripke structure not found for machine instance \(instance)")
            }
            return structure.initialStates.map { ScopedNode(instanceName: instance.name, node: $0) }
        }
        var jobs = [CombinedNode](nodes: scopedNodes, arrangement: arrangement)
        var processedJobs: Set<CombinedNode> = []
        let initialNodes = Set(jobs.map { Node(node: $0) })
        var nodes = initialNodes
        var edges: [Node: [Edge]] = [:]
        while let job = jobs.popLast() {
            guard !processedJobs.contains(job) else {
                continue
            }
            processedJobs.insert(job)
            nodes.insert(Node(node: job))
        }
        print("\(nodes.count) Nodes found!")
        print("\(edges.values.reduce(0) { $0 + $1.count }) Edges found!")
        self.init(
            nodes: Array(nodes),
            edges: edges,
            initialStates: initialNodes
        )
    }
}
