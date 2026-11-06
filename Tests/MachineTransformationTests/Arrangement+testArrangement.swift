import VHDLMachines
import VHDLParsing

/// Add test arrangement.
extension Arrangement {
    /// Add test arrangement.
    static let testArrangement = Arrangement(
        mappings: [
            .pingPong(): MachineMapping(
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
        // swiftlint:disable:next force_unwrapping
    )!
}

/// Add ping pong machine instance.
extension MachineInstance {
    /// PingPong instance.
    static func pingPong(name: VariableName = .m0) -> MachineInstance {
        MachineInstance(name: name, type: .pingPong)
    }
}
