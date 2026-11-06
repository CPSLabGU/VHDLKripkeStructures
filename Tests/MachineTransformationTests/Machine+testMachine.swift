import VHDLMachines
import VHDLParsing

/// Add test machine.
extension Machine {
    /// Ping Pong machine.
    static let pingPong = Machine(
        actions: [.onEntry, .onExit, .internal],
        includes: [
            .library(value: .ieee),
            .include(
                statement: UseStatement(nonEmptyComponents: [
                    .module(name: .ieee), .module(name: .stdLogic1164), .all,
                    // swiftlint:disable:next force_unwrapping
                ])!
            ),
        ],
        externalSignals: [PortSignal(type: .stdLogic, name: .y, mode: .output)],
        clocks: [Clock(name: .clk, frequency: 50, unit: .MHz)],
        drivingClock: 0,
        machineSignals: [],
        isParameterised: false,
        parameterSignals: [],
        returnableSignals: [],
        states: [
            State(
                name: .initial,
                actions: [
                    .onExit: .statement(
                        statement: .assignment(
                            name: .variable(reference: .variable(name: .y)),
                            value: .literal(value: .logic(value: .low))
                        )
                    )
                ],
                signals: [],
                externalVariables: [.y]
            ),
            State(
                name: .ping,
                actions: [
                    .onExit: .statement(
                        statement: .assignment(
                            name: .variable(reference: .variable(name: .y)),
                            value: .literal(value: .logic(value: .high))
                        )
                    )
                ],
                signals: [],
                externalVariables: [.y]
            ),
            State(
                name: .pong,
                actions: [
                    .onExit: .statement(
                        statement: .assignment(
                            name: .variable(reference: .variable(name: .y)),
                            value: .literal(value: .logic(value: .low))
                        )
                    )
                ],
                signals: [],
                externalVariables: [.y]
            ),
        ],
        transitions: [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1),
            Transition(condition: .conditional(condition: .literal(value: true)), source: 1, target: 2),
            Transition(condition: .conditional(condition: .literal(value: true)), source: 2, target: 1),
        ],
        initialState: 0,
        suspendedState: nil
    )
}
