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
        ) {
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
            let globalProperties = job.globalProperties
            let scopedNodes = edges.indices.map { index in
                edges[index]
                    .filter {
                        $0.hasSameGlobals(
                            instance: job.node.instances[index],
                            previousState: job.node.nodes[index].properties,
                            globals: globalProperties,
                            arrangement: arrangement
                        )
                    }
                    .map {
                        ScopedNode(instance: job.node.instances[index], node: $0.target)
                    }
            }
            let jobs: [Job]
            if scopedNodes.allSatisfy({ !$0.isEmpty }) {
                jobs = scopedNodes
                    .cartesianProduct
                    .map {
                        Job(node: CombinedNode(scopedNodes: $0), arrangement: arrangement)
                    }
            } else {
                jobs = []
            }
            let newEdges = jobs.map {
                Edge(target: Node(node: $0.node, arrangement: arrangement), cost: cost)
            }
            self.init(sourceNode: sourceNode, jobs: jobs, edges: newEdges)
        }
    }

    // swiftlint:enable function_body_length

    /// An array of jobs to process.
    var jobs: [Job] = []

    /// The combined nodes in the Kripke structure.
    var nodes: Set<Node> = []

    /// The edges for each combined node in the Kripke structure.
    var allEdges: [Node: [Edge]] = [:]

    /// Whether the job processor is currently running.
    var isRunning: Bool = false {
        willSet {
            if newValue && isRunning {
                fatalError("You cannot start simultaneous job processing within the same instance.")
            }
        }
    }

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
        self.isRunning = true
        defer { self.isRunning = false }
        let startState = arrangement.startState
        let globals = arrangement.globalVariables
        print("Finding reachable initial nodes...")
        try? FileHandle.standardOutput.synchronize()
        let scopedNodes = await arrangement.machines.keys.sorted { $0.name < $1.name }
            .concurrentMap { instance in
                guard let structure = kripkeStructures[instance],
                    let mapping = arrangement.reverseExternalMappings[instance.name]
                else {
                    fatalError("Kripke structure not found for machine instance \(instance)")
                }
                let reachableInitialStates = structure.initialStates
                    .filter {
                        $0.properties.allSatisfy {
                            guard let arrangementName = mapping[$0.key], globals.contains(arrangementName)
                            else {
                                return true
                            }
                            guard let startValue = startState[arrangementName] else {
                                fatalError(
                                    "Cannot find corresponding initial value for variable \(arrangementName)."
                                )
                            }
                            return startValue == $0.value
                        }
                    }
                // print(
                //     "Reduced \(structure.initialStates.count) initial states to "
                //         + "\(reachableInitialStates.count) in \(instance.name)"
                // )
                // print("Initial states: \(structure.initialStates.sorted())")
                return reachableInitialStates.map { ScopedNode(instance: instance, node: $0) }
            }
        let jobNodes = await scopedNodes.cartesianProduct.concurrentMap { CombinedNode(scopedNodes: $0) }
        let initialJobs = await jobNodes.concurrentMap { Job(node: $0, arrangement: arrangement) }
        print("...Done! Found \(jobNodes.count) initial nodes.")
        print("Folding Kripke structures together...")
        var scheduledJobs: Set<Job> = []
        self.jobs = initialJobs.filter { scheduledJobs.insert($0).inserted }
        let initialNodes = Set(await jobNodes.concurrentMap { Node(node: $0, arrangement: arrangement) })
        self.nodes = initialNodes
        self.allEdges = [:]
        var lastProgressUpdate = -Double.infinity
        var jobsProcessed = 0
        var inFlight = 0
        var jobDeltaStore = JobDeltaStore()
        var lastJobCount = self.jobs.count
        var deltas = 0
        var numberOfDeltas = 0
        func showJobsLeft(force: Bool = false) {
            let now = ProcessInfo.processInfo.systemUptime
            guard force || now - lastProgressUpdate >= 0.1 else { return }
            lastProgressUpdate = now
            let jobsLeft = self.jobs.count + inFlight
            let delta = jobsLeft - lastJobCount
            jobDeltaStore.append(delta: delta)
            deltas += delta
            numberOfDeltas += 1
            lastJobCount = jobsLeft
            let line =
                "\rJobs left: \(jobsLeft) | Jobs in progress: \(inFlight) "
                + "| Jobs Processed: \(jobsProcessed) | Job Delta Avg: \(deltas / numberOfDeltas) "
                + "| Job Delta (Last Second): \(jobDeltaStore.average)\u{1B}[K"
            FileHandle.standardOutput.write(Data(line.utf8))
        }
        try? FileHandle.standardOutput.synchronize()
        showJobsLeft()
        let workerCount = max(1, ProcessInfo.processInfo.activeProcessorCount)
        // swiftlint:disable:next closure_body_length
        await withTaskGroup(of: JobExpansion.self) { group in
            while !self.jobs.isEmpty || inFlight > 0 {
                while inFlight < workerCount, let job = self.jobs.popLast() {
                    guard self.allEdges[Node(node: job.node, arrangement: job.arrangement)] == nil else {
                        showJobsLeft()
                        continue
                    }
                    jobsProcessed += 1
                    inFlight += 1
                    group.addTask {
                        JobExpansion(
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
                guard !result.jobs.isEmpty, !result.edges.isEmpty else {
                    fatalError("Result for source node contains no jobs or edges: \(result.sourceNode)")
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
        print("...Done!")
        let edgeCount = self.allEdges.values.reduce(0) { $0 + $1.count }
        let totalNodeCount = kripkeStructures.reduce(0) { $0 + $1.value.nodes.count }
        let reduction = (Double(self.nodes.count) / Double(totalNodeCount) * 100.0 - 100.0)
        let nodeReduction = abs(reduction).formatted(.number.precision(.fractionLength(2)))
        let nodeIncreased = reduction < 0 ? "Decreased" : "Increased"
        let nodeReductionPrint = reduction < 0 ? "reduction" : "increase"
        print(
            "\(nodeIncreased) total nodes from \(totalNodeCount) to \(self.nodes.count) combined nodes "
                + "(\(nodeReduction)% \(nodeReductionPrint))."
        )
        let totalEdgeCount = kripkeStructures.reduce(0) {
            $0 + $1.value.edges.reduce(0) { $0 + $1.value.count }
        }
        let edgeRawReduction = (Double(edgeCount) / Double(totalEdgeCount) * 100.0 - 100.0)
        let edgeReduction = abs(edgeRawReduction).formatted(.number.precision(.fractionLength(2)))
        let edgeIncreased = edgeRawReduction < 0 ? "Decreased" : "Increased"
        let edgeReductionPrint = edgeRawReduction < 0 ? "reduction" : "increase"
        print(
            "\(edgeIncreased) total edges from \(totalEdgeCount) to \(edgeCount) combined edges "
                + "(\(edgeReduction)% \(edgeReductionPrint))."
        )
        print("Cyclomatic complexity: \(edgeCount - self.nodes.count + 2)")
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
                        fatalError("Failed to find previous value for key \($0.key) in previous state.")
                    }
                    return $0.value == previousValue
                default:
                    guard let reverseMapping = arrangement.reverseExternalMappings[instance.name],
                        let externalName = reverseMapping[$0.key]
                    else {
                        fatalError("Failed to find external value for key \($0.key).")
                    }
                    guard let globalValue = globals[externalName] else {
                        return true
                    }
                    return $0.value == globalValue
                }
            case .write:
                switch previousExternal.mode {
                case .input:
                    guard let previousValue = previousState[$0.key] else {
                        fatalError("Failed to find previous value for key \($0.key) in previous state.")
                    }
                    return $0.value == previousValue
                default:
                    return true
                }
            }
        }
    }
}
