import VHDLMachines
import VHDLParsing

/// Add helper functions to Arrangement.
extension Arrangement {
    /// The set of external variable names.
    var externalVariablesSet: Set<VariableName> {
        Set(self.externalSignals.map(\.name) + self.signals.map(\.name))
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
