import VHDLMachines
import VHDLParsing

/// Add test arrangement.
extension Arrangement {
    /// Add test arrangement.
    static let testArrangement = Arrangement(
        mappings: [
            MachineInstance(name: .m0, type: .pingPong): MachineMapping(
                machine: .pingPong,
                with: [VariableMapping(source: .extY, destination: .y)]
                // swiftlint:disable:next force_unwrapping
            )!
        ],
        externalSignals: [
            PortSignal(type: .stdLogic, name: .extX, mode: .input),
            PortSignal(type: .stdLogic, name: .extY, mode: .output),
        ],
        signals: [
            LocalSignal(type: .stdLogic, name: .x)
        ],
        clocks: [Clock(name: .clk, frequency: 50, unit: .MHz)]
    )
}
