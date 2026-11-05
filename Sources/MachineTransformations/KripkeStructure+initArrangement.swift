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
        let externalMappings = arrangement.externalMappings
        let reverseMappings = arrangement.reverseExternalMappings
        let scopedNodes = Array(initialNodes.values)
        var jobs = [CombinedNode](
            accumulator: [],
            nodeIndexes: [Int](repeating: 0, count: scopedNodes.count),
            nodes: scopedNodes,
            externalMappings: externalMappings,
            reverseMappings: reverseMappings
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

/// Add helper functions to Arrangement.
extension Arrangement {
    /// The set of external variable names.
    var externalVariablesSet: Set<VariableName> {
        Set(self.externalSignals.map(\.name))
    }

    /// The renamed external variables in each machine.
    var externalMappings: [VariableName: [VariableName: VariableName]] {
        Dictionary(
            uniqueKeysWithValues: self.machines.map {
                let mappings = $0.value.mappings.filter { externalVariablesSet.contains($0.source) }
                let mappingsDictionary = Dictionary(
                    uniqueKeysWithValues: (mappings.map { ($0.source, $0.destination) })
                )
                return ($0.key.name, mappingsDictionary)
            }
        )
    }

    /// The reverse relationship of `externalMappings`.
    var reverseExternalMappings: [VariableName: [VariableName: VariableName]] {
        Dictionary(
            uniqueKeysWithValues: self.machines.map {
                let mappings = $0.value.mappings.filter { externalVariablesSet.contains($0.source) }
                let reverseMappings = Dictionary(
                    uniqueKeysWithValues: (mappings.map { ($0.destination, $0.source) })
                )
                return ($0.key.name, reverseMappings)
            }
        )
    }
}

/// Add initialisation of a combined node.
extension Array where Element == CombinedNode {

    // swiftlint:disable function_body_length

    /// Attempt to combine kripke structures.
    init(
        accumulator: [CombinedNode],
        nodeIndexes: [Int],
        nodes: [[ScopedNode]],
        externalMappings: [VariableName: [VariableName: VariableName]],
        reverseMappings: [VariableName: [VariableName: VariableName]]
    ) {
        guard
            let currentOffset = nodeIndexes.indices.reversed()
                .first(where: {
                    nodes[$0].endIndex > nodeIndexes[$0]
                })
        else {
            self = accumulator
            return
        }
        let currentNodes = nodeIndexes.indices.map {
            nodes[$0][nodeIndexes[$0]]
        }
        let offsetIndex = nodeIndexes[currentOffset]
        let currentOffsetNode = nodes[currentOffset][offsetIndex]
        var accumulator = accumulator
        if currentNodes.indices.allSatisfy({
            currentNodes[$0]
                .hasSameExternals(
                    other: currentOffsetNode,
                    externalMappings: externalMappings,
                    reverseMappings: reverseMappings
                )
        }) {
            accumulator.append(CombinedNode(scopedNodes: currentNodes))
        }
        var newIndexes = nodeIndexes
        newIndexes[currentOffset] += 1
        let endIndex = newIndexes.endIndex
        if newIndexes[currentOffset] >= nodes[currentOffset].endIndex {
            guard currentOffset > 0 else {
                self = accumulator
                return
            }
            newIndexes[currentOffset - 1] += 1
            for i in currentOffset..<endIndex {
                newIndexes[i] = 0
            }
        } else {
            let nextIndex = newIndexes.index(after: currentOffset)
            if nextIndex < endIndex {
                for i in nextIndex..<endIndex {
                    newIndexes[i] = 0
                }
            }
        }
        self.init(
            accumulator: accumulator,
            nodeIndexes: newIndexes,
            nodes: nodes,
            externalMappings: externalMappings,
            reverseMappings: reverseMappings
        )
    }

    // swiftlint:enable function_body_length
}
