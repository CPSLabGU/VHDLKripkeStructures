import VHDLMachines
import VHDLParsing

/// Add test arrangement.
extension Arrangement {
    /// Add test arrangement.
    static let testArrangement = Arrangement(
        mappings: [
            .pingPong(): MachineMapping(
                machine: .pingPong,
                with: [
                    VariableMapping(source: .extY, destination: .y),
                    VariableMapping(source: .x, destination: .timerPulse),
                ]
                // swiftlint:disable:next force_unwrapping
            )!,
            .timer(): MachineMapping(
                machine: .timer,
                with: [
                    VariableMapping(source: .x, destination: .pulse)
                ]
                // swiftlint:disable:next force_unwrapping
            )!,
        ],
        externalSignals: [
            // PortSignal(type: .stdLogic, name: .extX, mode: .input),
            PortSignal(type: .stdLogic, name: .extY, mode: .output)
        ],
        signals: [
            LocalSignal(type: .stdLogic, name: .x)
        ],
        clocks: [.clk50]
        // swiftlint:disable:next force_unwrapping
    )!

    /// Add arrangement that only includes a ping pong machine.
    static let pingPongArrangement = Arrangement(
        mappings: [
            .pingPong(): MachineMapping(
                machine: .pingPong,
                with: [
                    VariableMapping(source: .extY, destination: .y),
                    VariableMapping(source: .x, destination: .timerPulse),
                ]
                // swiftlint:disable:next force_unwrapping
            )!
        ],
        externalSignals: [
            // PortSignal(type: .stdLogic, name: .extX, mode: .input),
            PortSignal(type: .stdLogic, name: .extY, mode: .output)
        ],
        signals: [
            LocalSignal(type: .stdLogic, name: .x)
        ],
        clocks: [.clk50]
        // swiftlint:disable:next force_unwrapping
    )!

    /// Add arrangement that includes a PingPong and QuickTimer machine.
    static let pingPongQuickTimerArrangement = Arrangement(
        mappings: [
            .pingPong(): MachineMapping(
                machine: .pingPong,
                with: [
                    VariableMapping(source: .extY, destination: .y),
                    VariableMapping(source: .x, destination: .timerPulse),
                ]
                // swiftlint:disable:next force_unwrapping
            )!,
            .quickTimer(): MachineMapping(
                machine: .quickTimer,
                with: [
                    VariableMapping(source: .x, destination: .pulse)
                ]
                // swiftlint:disable:next force_unwrapping
            )!,
        ],
        externalSignals: [
            // PortSignal(type: .stdLogic, name: .extX, mode: .input),
            PortSignal(type: .stdLogic, name: .extY, mode: .output)
        ],
        signals: [
            LocalSignal(type: .stdLogic, name: .x)
        ],
        clocks: [.clk50]
        // swiftlint:disable:next force_unwrapping
    )!
}

/// Add ping pong machine instance.
extension MachineInstance {
    /// PingPong instance.
    static func pingPong(name: VariableName = .m0) -> MachineInstance {
        MachineInstance(name: name, type: .pingPong)
    }

    /// Timer instance.
    static func timer(name: VariableName = .m1) -> MachineInstance {
        MachineInstance(name: name, type: .timer)
    }

    /// QuickTimer instance.
    static func quickTimer(name: VariableName = .m2) -> MachineInstance {
        MachineInstance(name: name, type: .quickTimer)
    }
}
