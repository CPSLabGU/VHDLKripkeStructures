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
    public convenience init(arrangement: Arrangement, kripkeStructures: [MachineInstance: KripkeStructure])
        async
    {
        print("Attempting to fold Kripke structures together...")
        let scopedNodes = arrangement.machines.keys.sorted { $0.name < $1.name }
            .map { instance in
                guard let structure = kripkeStructures[instance] else {
                    fatalError("Kripke structure not found for machine instance \(instance)")
                }
                return structure.initialStates.map { ScopedNode(instance: instance, node: $0) }
            }
        let jobNodes = await [CombinedNode](nodes: scopedNodes, arrangement: arrangement, globalState: [:])
        var jobs = await jobNodes.concurrentMap { Job(node: $0, arrangement: arrangement) }
        var processedJobs: Set<Job> = []
        let initialNodes = Set(await jobNodes.concurrentMap { Node(node: $0, arrangement: arrangement) })
        var nodes = initialNodes
        var allEdges: [Node: [Edge]] = [:]
        var lastProgressUpdate = -Double.infinity
        var jobsProcessed = 0
        func showJobsLeft(force: Bool = false) {
            let now = ProcessInfo.processInfo.systemUptime
            guard force || now - lastProgressUpdate >= 0.1 else { return }
            lastProgressUpdate = now
            let line = "\rJobs left: \(jobs.count), Jobs Processed: \(jobsProcessed)\u{1B}[K"
            FileHandle.standardOutput.write(Data(line.utf8))
        }
        showJobsLeft()
        while let job = jobs.popLast() {
            jobsProcessed += 1
            showJobsLeft()
            guard !processedJobs.contains(job) else {
                continue
            }
            processedJobs.insert(job)
            let sourceNode = Node(node: job.node, arrangement: arrangement)
            nodes.insert(sourceNode)
            let kripkeStructures = job.node.instances.compactMap { kripkeStructures[$0] }
            guard kripkeStructures.count == job.node.instances.count else {
                fatalError("Kripke structures not found for all instances in the combined node")
            }
            let edges = kripkeStructures.indices.map {
                guard let edges = kripkeStructures[$0].edges[job.node.nodes[$0]] else {
                    fatalError(
                        "Edges not found for node \(job.node.nodes[$0]) in "
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
            let scopedNodes = await edges.indices.concurrentMap { index in
                await edges[index]
                    .concurrentMap {
                        ScopedNode(instance: job.node.instances[index], node: $0.target)
                    }
            }
            let nodes = await [CombinedNode](
                nodes: scopedNodes,
                arrangement: arrangement,
                globalState: job.globalProperties
            )
            .concurrentMap {
                Job(node: $0, arrangement: arrangement)
            }
            jobs.append(contentsOf: nodes.filter { !processedJobs.contains($0) })
            let newEdges = await nodes.concurrentMap {
                Edge(target: Node(node: $0.node, arrangement: arrangement), cost: cost)
            }
            guard allEdges[sourceNode] == nil else {
                fatalError("Edges for source node \(sourceNode) already exist")
            }
            allEdges[sourceNode] = newEdges
        }
        showJobsLeft(force: true)
        FileHandle.standardOutput.write(Data("\n".utf8))
        let edgeCount = allEdges.values.reduce(0) { $0 + $1.count }
        let totalNodeCount = kripkeStructures.reduce(0) { $0 + $1.value.nodes.count }
        let nodeReduction = (Double(nodes.count) / Double(totalNodeCount) * 100.0 - 100.0)
            .formatted(.number.precision(.fractionLength(2)))
        print(
            "Increased total nodes from \(totalNodeCount) to \(nodes.count) combined nodes "
                + "(\(nodeReduction)% increase)."
        )
        let totalEdgeCount = kripkeStructures.reduce(0) {
            $0 + $1.value.edges.reduce(0) { $0 + $1.value.count }
        }
        let edgeReduction = (Double(edgeCount) / Double(totalEdgeCount) * 100.0 - 100.0)
            .formatted(.number.precision(.fractionLength(2)))
        print(
            "Increased total edges from \(totalEdgeCount) to \(edgeCount) combined edges "
                + "(\(edgeReduction)% increase)."
        )
        self.init(
            nodes: Array(nodes),
            edges: allEdges,
            initialStates: initialNodes
        )
    }

    // swiftlint:enable function_body_length
}
