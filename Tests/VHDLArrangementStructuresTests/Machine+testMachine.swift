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
        externalSignals: [
            PortSignal(type: .stdLogic, name: .y, mode: .output),
            PortSignal(type: .stdLogic, name: .timerPulse, mode: .input),
        ],
        clocks: [.clk50],
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
                externalVariables: [.y, .timerPulse]
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
                externalVariables: [.y, .timerPulse]
            ),
        ],
        transitions: [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1),
            Transition(
                condition: .conditional(
                    condition: .comparison(
                        value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(name: .counter))),
                            rhs: .literal(value: .bit(value: .high))
                        )
                    )
                ),
                source: 1,
                target: 2
            ),
            Transition(
                condition: .conditional(
                    condition: .comparison(
                        value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(name: .counter))),
                            rhs: .literal(value: .bit(value: .high))
                        )
                    )
                ),
                source: 2,
                target: 1
            ),
        ],
        initialState: 0,
        suspendedState: nil
    )

    /// The timer machine.
    static let timer = Machine(
        actions: [.onEntry, .onExit, .internal],
        includes: [
            .library(value: .ieee),
            .include(
                statement: UseStatement(nonEmptyComponents: [
                    .module(name: .ieee), .module(name: .stdLogic1164), .all,
                    // swiftlint:disable:next force_unwrapping
                ])!
            ),
            .include(
                statement: UseStatement(nonEmptyComponents: [
                    .module(name: .ieee), .module(name: .numericStd), .all,
                    // swiftlint:disable:next force_unwrapping
                ])!
            ),
        ],
        externalSignals: [PortSignal(type: .stdLogic, name: .pulse, mode: .output)],
        clocks: [.clk50],
        drivingClock: 0,
        machineSignals: [
            LocalSignal(
                type: .ranged(
                    type: .unsigned(
                        size: .downto(
                            upper: .literal(value: .integer(value: 3)),
                            lower: .literal(value: .integer(value: 0))
                        )
                    )
                ),
                name: .counter
            )
        ],
        isParameterised: false,
        parameterSignals: [],
        returnableSignals: [],
        states: [
            State(
                name: .initial,
                actions: [
                    .onExit: .blocks(blocks: [
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: .pulse)),
                                value: .literal(value: .bit(value: .low))
                            )
                        ),
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: .counter)),
                                value: .literal(value: .integer(value: 0))
                            )
                        ),
                    ])
                ],
                signals: [],
                externalVariables: [.pulse]
            ),
            State(
                name: .countTime,
                actions: [
                    .onExit: .blocks(blocks: [
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: .pulse)),
                                value: .literal(value: .bit(value: .high))
                            )
                        ),
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: .counter)),
                                value: .literal(value: .integer(value: 0))
                            )
                        ),
                    ]),
                    .internal: .blocks(blocks: [
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: .pulse)),
                                value: .literal(value: .bit(value: .low))
                            )
                        ),
                        .statement(
                            statement: .assignment(
                                name: .variable(reference: .variable(name: .counter)),
                                value: .binary(
                                    operation: .addition(
                                        lhs: .reference(
                                            variable: .variable(reference: .variable(name: .counter))
                                        ),
                                        rhs: .literal(value: .integer(value: 1))
                                    )
                                )
                            )
                        ),
                    ]),
                ],
                signals: [],
                externalVariables: [.pulse]
            ),
        ],
        transitions: [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1),
            Transition(
                condition: .conditional(
                    condition: .comparison(
                        value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(name: .counter))),
                            rhs: .literal(value: .integer(value: 100))
                        )
                    )
                ),
                source: 1,
                target: 1
            ),
        ],
        initialState: 0,
        suspendedState: nil
    )
}

/// Add common clocks.
extension Clock {
    /// 50 MHz clk.
    static let clk50 = Clock(name: .clk, frequency: 50, unit: .MHz)
}
