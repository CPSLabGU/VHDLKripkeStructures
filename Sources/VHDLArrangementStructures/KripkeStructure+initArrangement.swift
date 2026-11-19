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
        async
    {
        let processor = JobProcessor()
        let structure = await processor.combineKripkeStructures(
            arrangement: arrangement,
            kripkeStructures: kripkeStructures
        )
        self.init(nodes: structure.nodes, edges: structure.edges, initialStates: structure.initialStates)
    }

}

// /// Compute the outgoing edges and successor jobs without modifying the graph.
// private func expand(
//     job: Job,
//     arrangement: Arrangement,
//     kripkeStructures: [MachineInstance: KripkeStructure]
// ) async -> JobExpansion {
//     let sourceNode = Node(node: job.node, arrangement: arrangement)
//     let structures = job.node.instances.compactMap { kripkeStructures[$0] }
//     guard structures.count == job.node.instances.count else {
//         fatalError("Kripke structures not found for all instances in the combined node")
//     }
//     let edges = structures.indices.map {
//         guard let edges = structures[$0].edges[job.node.nodes[$0]] else {
//             fatalError(
//                 "Edges not found for node \(job.node.nodes[$0]) in "
//                     + "kripke structure \(structures[$0])"
//             )
//         }
//         return edges
//     }
//     guard !edges.isEmpty, edges.allSatisfy({ !$0.isEmpty }),
//         edges.allSatisfy({ edgeList in edgeList.allSatisfy { edgeList[0].cost == $0.cost } })
//     else {
//         fatalError("Edges are either empty or have inconsistent costs for combined node \(job)")
//     }
//     let cost = edges[0][0].cost
//     let scopedNodes = await edges.indices.concurrentMap { index in
//         await edges[index]
//             // .filter {
//             //     $0.hasSameGlobals(
//             //         instance: job.node.instances[index],
//             //         globals: job.globalProperties,
//             //         arrangement: arrangement
//             //     )
//             // }
//             .concurrentMap {
//                 ScopedNode(instance: job.node.instances[index], node: $0.target)
//             }
//     }
//     let jobs = await [CombinedNode](
//         nodes: scopedNodes,
//         arrangement: arrangement,
//         globalState: job.globalProperties
//     )
//     .concurrentMap {
//         Job(node: $0, arrangement: arrangement)
//     }
//     let newEdges = await jobs.concurrentMap {
//         Edge(target: Node(node: $0.node, arrangement: arrangement), cost: cost)
//     }
//     return JobExpansion(sourceNode: sourceNode, jobs: jobs, edges: newEdges)
// }

// extension Edge {
//     func hasSameGlobals(
//         instance: MachineInstance,
//         globals: [VariableName: SignalLiteral],
//         arrangement: Arrangement
//     ) -> Bool {
//         guard let reverseMapping = arrangement.reverseExternalMappings[instance.name] else {
//             return true
//         }
//         let externalSignals = arrangement.externals(instance: instance)
//         return self.target.properties.allSatisfy {
//             guard let externalName = reverseMapping[$0.key] else {
//                 return true
//             }
//             guard let previousExternal = externalSignals[externalName] else {
//                 guard let previousValue = globals[externalName] else {
//                     return true
//                 }
//                 return $0.value == previousValue
//             }
//             let target = self.target
//             switch target.type {
//             case .read:
//                 switch $0.
//             case .write:
//             }
//         }
//     }
// }
