// ScientificQuantity+arithmetic.swift
// VHDLKripkeStructures
// 
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.

import Foundation

extension ScientificQuantity: Numeric, ExpressibleByFloatLiteral {

    public typealias FloatLiteralType = Double

    public typealias Magnitude = Double

    public typealias IntegerLiteralType = UInt

    public static let zero = ScientificQuantity(coefficient: 0, exponent: 0)

    public var magnitude: Double {
        Double(self.coefficient) * pow(10.0, Double(self.exponent))
    }

    public init(floatLiteral value: Double) {
        guard value.isFinite else {
            fatalError("Integer overflow trying to create Scientific Quantity for \(value)")
        }
        guard !value.isZero else {
            self.init(coefficient: 0, exponent: 0)
            return
        }
        let components = String(value).components(separatedBy: ".")
        guard components.count == 2 else {
            self.init(quantity: ScientificQuantity(coefficient: UInt(value), exponent: 0))
            return
        }
        let exponent = -components[1].count
        guard components[0] != "0" else {
            guard let firstIndex = components[1].firstIndex(where: { $0 != "0" }) else {
                guard let coefficient = UInt(components[1]) else {
                    fatalError("Integer overflow trying to create Scientific Quantity for \(value)")
                }
                self.init(coefficient: coefficient, exponent: exponent)
                return
            }
            guard let coefficient = UInt(
                components[1].dropFirst(firstIndex.utf16Offset(in: components[1]))
            ) else {
                fatalError("Integer overflow trying to create Scientific Quantity for \(value)")
            }
            self.init(coefficient: coefficient, exponent: exponent)
            return
        }
        guard let newCoefficient = UInt(components[0] + components[1]) else {
            fatalError("Integer overflow trying to create Scientific Quantity for \(value)")
        }
        self.init(quantity: ScientificQuantity(coefficient: newCoefficient, exponent: exponent))
    }

    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard source >= 0 else {
            return nil
        }
        self.init(integerLiteral: UInt(source))
    }

    public init(integerLiteral value: UInt) {
        let trailingZeros = value.trailingZeros
        self.init(
            coefficient: value / UInt(pow(10.0, Double(trailingZeros)).rounded()), exponent: trailingZeros
        )
    }

    public init(quantity: ScientificQuantity) {
        let rawCoefficient = quantity.coefficient
        let newExponent = quantity.exponent + rawCoefficient.trailingZeros
        let newCoefficient = rawCoefficient / UInt(pow(10.0, Double(rawCoefficient.trailingZeros)).rounded())
        self.init(coefficient: newCoefficient, exponent: newExponent)
    }

    public static func + (lhs: ScientificQuantity, rhs: ScientificQuantity) -> ScientificQuantity {
        Self.binaryOperation(lhs: lhs, rhs: rhs, operation: +)
    }

    public static func - (lhs: ScientificQuantity, rhs: ScientificQuantity) -> ScientificQuantity {
        Self.binaryOperation(lhs: lhs, rhs: rhs, operation: -)
    }

    public static func * (lhs: ScientificQuantity, rhs: ScientificQuantity) -> ScientificQuantity {
        Self.binaryOperation(lhs: lhs, rhs: rhs, operation: *)
    }

    public static func *= (lhs: inout ScientificQuantity, rhs: ScientificQuantity) {
        lhs = lhs * rhs
    }

    static func binaryOperation(
        lhs: ScientificQuantity, rhs: ScientificQuantity, operation: (UInt, UInt) -> UInt
    ) -> ScientificQuantity {
        guard lhs.exponent != rhs.exponent else {
            return ScientificQuantity(
                quantity: ScientificQuantity(
                    coefficient: operation(lhs.coefficient, rhs.coefficient), exponent: lhs.exponent
                )
            )
        }
        let minExponent = min(lhs.exponent, rhs.exponent)
        let lhsDiff = lhs.exponent - minExponent
        let rhsDiff = rhs.exponent - minExponent
        let lhsAmount: UInt
        let rhsAmount: UInt
        let exponent: Int
        if lhsDiff > rhsDiff {
            exponent = rhs.exponent
            lhsAmount = lhs.coefficient * UInt(pow(10.0, Double(lhsDiff)).rounded())
            rhsAmount = rhs.coefficient
        } else {
            exponent = lhs.exponent
            lhsAmount = lhs.coefficient
            rhsAmount = rhs.coefficient * UInt(pow(10.0, Double(rhsDiff)).rounded())
        }
        let newCoefficient = operation(lhsAmount, rhsAmount)
        return ScientificQuantity(
            quantity: ScientificQuantity(coefficient: newCoefficient, exponent: exponent)
        )
    }

}

extension UInt {

    var trailingZeros: Int {
        let description = String(String(self).reversed())
        guard let firstIndex = description.firstIndex(where: { $0 != "0" }) else {
            return 0
        }
        return Int(firstIndex.utf16Offset(in: description))
    }

}
