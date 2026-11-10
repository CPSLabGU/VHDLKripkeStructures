import VHDLParsing

// swiftlint:disable force_unwrapping

/// Add helper names for testing.
extension VariableName {
    /// clk.
    static let clk = VariableName(rawValue: "clk")!

    /// counter.
    static let counter = VariableName(rawValue: "counter")!

    /// CountTime.
    static let countTime = VariableName(rawValue: "CountTime")!

    /// extX.
    static let extX = VariableName(rawValue: "extX")!

    /// extY.
    static let extY = VariableName(rawValue: "extY")!

    /// IEEE
    static let ieee = VariableName(rawValue: "IEEE")!

    /// Initial.
    static let initial = VariableName(rawValue: "Initial")!

    /// Internal.
    static let `internal` = VariableName(rawValue: "Internal")!

    /// OnEntry.
    static let onEntry = VariableName(rawValue: "OnEntry")!

    /// OnExit.
    static let onExit = VariableName(rawValue: "OnExit")!

    /// M0.
    static let m0 = VariableName(rawValue: "M0")!

    /// M1.
    static let m1 = VariableName(rawValue: "M1")!

    /// numberic_std.
    static let numericStd = VariableName(rawValue: "numeric_std")!

    /// Ping.
    static let ping = VariableName(rawValue: "Ping")!

    /// PingPong.
    static let pingPong = VariableName(rawValue: "PingPong")!

    /// Pong.
    static let pong = VariableName(rawValue: "Pong")!

    /// pulse.
    static let pulse = VariableName(rawValue: "pulse")!

    /// std_logic_1164.
    static let stdLogic1164 = VariableName(rawValue: "std_logic_1164")!

    /// Timer.
    static let timer = VariableName(rawValue: "Timer")!

    /// timerPulse.
    static let timerPulse = VariableName(rawValue: "timerPulse")!

    /// x.
    static let x = VariableName(rawValue: "x")!

    /// y.
    static let y = VariableName(rawValue: "y")!
}

// swiftlint:enable force_unwrapping
