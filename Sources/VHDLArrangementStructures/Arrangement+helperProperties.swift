import VHDLMachines
import VHDLParsing

/// Add helper functions to Arrangement.
extension Arrangement {
    /// The set of external variable names.
    var externalVariablesSet: Set<ArrangementVariableName> {
        Set(self.externalSignals.map(\.name) + self.signals.map(\.name))
    }

    /// The set of global variables.
    var globalVariables: Set<ArrangementVariableName> {
        Set(self.signals.map(\.name))
    }

    /// The renamed external variables in each machine.
    var externalMappings: [MachineInstanceName: [ArrangementVariableName: MachineVariableName]] {
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
    var reverseExternalMappings: [MachineInstanceName: [MachineVariableName: ArrangementVariableName]] {
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

    /// The starting state of the global and external variables.
    var startState: [ArrangementVariableName: SignalLiteral] {
        let externals = self.externalSignals.map {
            ($0.name, $0.defaultValue?.literal ?? $0.type.signal.default)
        }
        let globals = self.signals.map {
            ($0.name, $0.defaultValue?.literal ?? $0.type.signal.default)
        }
        return Dictionary(uniqueKeysWithValues: externals + globals)
    }

    /// Fetch the external varible definitions for a machine instance.
    func externals(instance: MachineInstance) -> [MachineVariableName: PortSignal] {
        guard let machineMapping = self.machines[instance] else {
            fatalError("Machine for instance \(instance.name) not found in arrangement")
        }
        return Dictionary(uniqueKeysWithValues: machineMapping.machine.externalSignals.map { ($0.name, $0) })
    }
}
