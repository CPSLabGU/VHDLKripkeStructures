import VHDLParsing

/// Add helpers for signal types.
extension SignalType {
    /// The default literal value for the signal type.
    var `default`: SignalLiteral {
        switch self {
        case .bit, .stdLogic, .stdULogic:
            return .bit(value: .low)
        case .boolean:
            return .boolean(value: false)
        case .natural, .integer:
            return .integer(value: 0)
        case .positive:
            return .integer(value: 1)
        case .real:
            return .decimal(value: 0.0)
        case .ranged(let type):
            switch type {
            case .bitVector(let size), .stdLogicVector(let size), .stdULogicVector(let size):
                return .vector(
                    // swiftlint:disable:next force_unwrapping
                    value: .bits(value: BitVector(values: [BitLiteral](repeating: .low, count: size.size!)))
                )
            case .integer, .signed, .unsigned:
                return .integer(value: 0)
            }
        }
    }
}

/// Add helpers for types.
extension Type {
    /// The signal type for the type if it is a signal.
    var signal: SignalType {
        switch self {
        case .signal(let type):
            return type
        default:
            fatalError("Cannot get signal literal for non-signal type")
        }
    }
}

/// Add helpers for expressions.
extension Expression {
    /// Forcefully get the literal value for the expression.
    var literal: SignalLiteral {
        switch self {
        case .literal(let value):
            return value
        default:
            fatalError("Cannot get literal for non-literal expression")
        }
    }
}
