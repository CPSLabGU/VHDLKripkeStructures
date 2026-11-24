import Foundation
import VHDLKripkeStructures
import VHDLMachines
import VHDLParsing

/// A job processor that manages the expansion of jobs and the combination of Kripke structures into a single
/// graph.
actor JobProcessor {
    /// The graph changes produced by expanding a job.
    private struct JobExpansion: Sendable {
        /// The node from which the edges originate.
        let sourceNode: Node

        /// The jobs reached by the edges.
        let jobs: [Job]

        /// The outgoing edges of the source node.
        let edges: [Edge]

        /// Property initialiser.
        init(sourceNode: Node, jobs: [Job], edges: [Edge]) {
            self.sourceNode = sourceNode
            self.jobs = jobs
            self.edges = edges
        }

        // swiftlint:disable function_body_length

        /// Compute the outgoing edges and successor jobs without modifying the graph.
        init(
            job: Job,
            arrangement: Arrangement,
            kripkeStructures: [MachineInstance: KripkeStructure]
        ) async {
            let sourceNode = Node(node: job.node, arrangement: arrangement)
            let structures = job.node.instances.compactMap { kripkeStructures[$0] }
            guard structures.count == job.node.instances.count else {
                fatalError("Kripke structures not found for all instances in the combined node")
            }
            let edges = structures.indices.map {
                guard let edges = structures[$0].edges[job.node.nodes[$0]] else {
                    fatalError(
                        "Edges not found for node \(job.node.nodes[$0]) in "
                            + "kripke structure \(structures[$0])"
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
                    .filter {
                        edges.count == 1
                            || $0.hasSameGlobals(
                                instance: job.node.instances[index],
                                previousState: job.node.nodes[index].properties,
                                globals: job.globalProperties,
                                arrangement: arrangement
                            )
                    }
                    .concurrentMap {
                        ScopedNode(instance: job.node.instances[index], node: $0.target)
                    }
            }
            let jobs: [Job]
            if scopedNodes.allSatisfy({ !$0.isEmpty }) {
                jobs =
                    await scopedNodes
                    .cartesianProduct
                    .concurrentMap {
                        CombinedNode(scopedNodes: $0)
                    }
                    .concurrentMap {
                        Job(node: $0, arrangement: arrangement)
                    }
            } else {
                jobs = []
            }
            let newEdges = await jobs.concurrentMap {
                Edge(target: Node(node: $0.node, arrangement: arrangement), cost: cost)
            }
            self.init(sourceNode: sourceNode, jobs: jobs, edges: newEdges)
        }
    }

    // swiftlint:enable function_body_length

    /// An array of jobs to process.
    var jobs: [Job] = []

    /// The set of processed jobs.
    var processedJobs: Set<Job> = []

    /// The combined nodes in the Kripke structure.
    var nodes: Set<Node> = []

    /// The edges for each combined node in the Kripke structure.
    var allEdges: [Node: [Edge]] = [:]

    /// Initialize an empty job processor.
    init() {}

    // swiftlint:disable function_body_length

    /// Create a combined kripke structure from all machines in the arrangement.
    /// - Parameters:
    ///   - arrangement: The arrangement containing the machines.
    ///   - kripkeStructures: A dictionary mapping machine instances to their kripke structures.
    /// - Throws: An error if the kripke structure cannot be created.
    func combineKripkeStructures(
        arrangement: Arrangement,
        kripkeStructures: [MachineInstance: KripkeStructure]
    ) async -> KripkeStructure {
        print("Attempting to fold Kripke structures together...")
        let startState = arrangement.startState
        let scopedNodes = arrangement.machines.keys.sorted { $0.name < $1.name }
            .map { instance in
                guard let structure = kripkeStructures[instance],
                    let mapping = arrangement.reverseExternalMappings[instance.name]
                else {
                    fatalError("Kripke structure not found for machine instance \(instance)")
                }
                let reachableInitialStates = structure.initialStates.filter {
                    $0.properties.allSatisfy {
                        guard let arrangementName = mapping[$0.key] else {
                            return true
                        }
                        return startState[arrangementName] == $0.value
                    }
                }
                return reachableInitialStates.map { ScopedNode(instance: instance, node: $0) }
            }
        let jobNodes = await [CombinedNode](nodes: scopedNodes, arrangement: arrangement, currentState: [:])
        let initialJobs = await jobNodes.concurrentMap { Job(node: $0, arrangement: arrangement) }
        var scheduledJobs: Set<Job> = []
        self.jobs = initialJobs.filter { scheduledJobs.insert($0).inserted }
        self.processedJobs = []
        let initialNodes = Set(await jobNodes.concurrentMap { Node(node: $0, arrangement: arrangement) })
        self.nodes = initialNodes
        self.allEdges = [:]
        var lastProgressUpdate = -Double.infinity
        var jobsProcessed = 0
        var inFlight = 0
        func showJobsLeft(force: Bool = false) {
            let now = ProcessInfo.processInfo.systemUptime
            guard force || now - lastProgressUpdate >= 0.1 else { return }
            lastProgressUpdate = now
            let line =
                "\rJobs left: \(self.jobs.count + inFlight) | Jobs in progress: \(inFlight) "
                + "| Jobs Processed: \(jobsProcessed) | Nodes: \(self.nodes.count)\u{1B}[K"
            FileHandle.standardOutput.write(Data(line.utf8))
        }
        showJobsLeft()
        let workerCount = max(1, ProcessInfo.processInfo.activeProcessorCount)
        await withTaskGroup(of: JobExpansion.self) { group in
            while !self.jobs.isEmpty || inFlight > 0 {
                while inFlight < workerCount, let job = self.jobs.popLast() {
                    guard self.processedJobs.insert(job).inserted else {
                        showJobsLeft()
                        continue
                    }
                    jobsProcessed += 1
                    inFlight += 1
                    group.addTask {
                        await JobExpansion(
                            job: job,
                            arrangement: arrangement,
                            kripkeStructures: kripkeStructures
                        )
                    }
                    showJobsLeft()
                }
                guard let result = await group.next() else {
                    break
                }
                inFlight -= 1
                self.nodes.insert(result.sourceNode)
                self.jobs.append(contentsOf: result.jobs.filter { scheduledJobs.insert($0).inserted })
                guard self.allEdges[result.sourceNode] == nil else {
                    fatalError("Edges for source node \(result.sourceNode) already exist")
                }
                self.allEdges[result.sourceNode] = result.edges
            }
        }
        showJobsLeft(force: true)
        FileHandle.standardOutput.write(Data("\n".utf8))
        let edgeCount = self.allEdges.values.reduce(0) { $0 + $1.count }
        let totalNodeCount = kripkeStructures.reduce(0) { $0 + $1.value.nodes.count }
        let nodeReduction = (Double(self.nodes.count) / Double(totalNodeCount) * 100.0 - 100.0)
            .formatted(.number.precision(.fractionLength(2)))
        print(
            "Increased total nodes from \(totalNodeCount) to \(self.nodes.count) combined nodes "
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
        return KripkeStructure(
            nodes: Array(self.nodes),
            edges: self.allEdges,
            initialStates: initialNodes
        )
    }

    // swiftlint:enable function_body_length
}

/// Add helpers for filtering edges.
extension Edge {

    /// Check whether the edge is valid from the previous state.
    func hasSameGlobals(
        instance: MachineInstance,
        previousState: [MachineVariableName: SignalLiteral],
        globals: [ArrangementVariableName: SignalLiteral],
        arrangement: Arrangement
    ) -> Bool {
        let externalSignals = arrangement.externals(instance: instance)
        // swiftlint:disable:next closure_body_length
        return self.target.properties.allSatisfy {
            guard let previousExternal = externalSignals[$0.key] else {
                return true
            }
            let target = self.target
            switch target.type {
            case .read:
                switch previousExternal.mode {
                case .output:
                    guard let previousValue = previousState[$0.key] else {
                        print("Failed to find previous value for key \($0.key) in previous state.")
                        return true
                    }
                    return $0.value == previousValue
                default:
                    guard let reverseMapping = arrangement.reverseExternalMappings[instance.name],
                        let externalName = reverseMapping[$0.key], let globalValue = globals[externalName]
                    else {
                        print("Failed to find global value for key \($0.key) in globals.")
                        return true
                    }
                    return $0.value == globalValue
                }
            case .write:
                switch previousExternal.mode {
                case .input:
                    guard let previousValue = previousState[$0.key] else {
                        print("Failed to find previous value for key \($0.key) in previous state.")
                        return true
                    }
                    return $0.value == previousValue
                default:
                    return true
                }
            }
        }
    }
}
