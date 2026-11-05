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
        let initialNodes = Dictionary(
            uniqueKeysWithValues: arrangement.machines.keys.map { instance in
                guard let structure = kripkeStructures[instance] else {
                    fatalError("Kripke structure not found for machine instance \(instance)")
                }
                return (
                    instance.name,
                    structure.initialStates.map { ScopedNode(instanceName: instance.name, node: $0) }
                )
            }
        )
        let scopedNodes = Array(initialNodes.values)
        var jobs = [CombinedNode](
            accumulator: [],
            nodeIndexes: [Int](repeating: 0, count: scopedNodes.count),
            nodes: scopedNodes,
            arrangement: arrangement
        )
        var processedJobs: Set<CombinedNode> = []
        while let job = jobs.popLast() {
            guard !processedJobs.contains(job) else {
                continue
            }
            processedJobs.insert(job)
        }
    }
}
