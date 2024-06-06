// ScientificQuantity.swift
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

/// A quantity in scientific notation.
public struct ScientificQuantity: Equatable, Hashable, Codable, Sendable, Quantifiable, SIRepresentable {

    /// The coefficient of the quantity.
    public let coefficient: UInt

    /// The exponent of the base-10 quantity.
    public let exponent: Int

    /// The quantity value without scientific notation.
    @inlinable public var quantity: Double {
        Double(coefficient) * pow(10.0, Double(exponent))
    }

    /// The quantity represented to the closest SI-prefix (exponent multiple of 3).
    @inlinable public var siValue: UnnormalisedScientificQuantity {
        guard self.coefficient != 0 else {
            return UnnormalisedScientificQuantity(coefficient: 0, exponent: 0)
        }
        guard self.exponent >= 0 else {
            let dividend = abs(self.exponent % 3)
            guard dividend != 0 else {
                return UnnormalisedScientificQuantity(quantity: self)
            }
            let remainder = 3 - dividend
            let newExponent = self.exponent - remainder
            guard let base10 = UInt("1\(String(repeating: "0", count: remainder))") else {
                return UnnormalisedScientificQuantity(quantity: self)
            }
            let newCoefficient = self.coefficient * base10
            return UnnormalisedScientificQuantity(coefficient: newCoefficient, exponent: newExponent)
        }
        let remainder = self.exponent % 3
        guard remainder != 0 else {
            return UnnormalisedScientificQuantity(quantity: self)
        }
        let newExponent = self.exponent - remainder
        guard let base10 = UInt("1\(String(repeating: "0", count: remainder))") else {
            return UnnormalisedScientificQuantity(quantity: self)
        }
        let newCoefficient = self.coefficient * base10
        return UnnormalisedScientificQuantity(coefficient: newCoefficient, exponent: newExponent)
    }

    /// Creates a new `ScientificQuantity` from the stored properties.
    /// - Parameters:
    ///   - coefficient: The coefficient of the quantity.
    ///   - exponent: The exponent of the base-10 quantity.
    @inlinable
    public init(coefficient: UInt, exponent: Int) {
        self.init(
            quantity: ScientificQuantity(normalisedCoefficient: coefficient, normalisedExponent: exponent)
        )
    }

    /// Creates a new `ScientificQuantity` from a `SIRepresentable` value.
    /// - Parameter value: The value to create the quantity from.
    @inlinable
    public init<T>(SIValue value: T) where T: SIRepresentable {
        self.init(coefficient: value.coefficient, exponent: value.exponent)
    }

    /// Create the quantity assuming the coefficient is normalised with the exponent.
    /// - Parameters:
    ///   - normalisedCoefficient: The normalised coefficient.
    ///   - normalisedExponent: The normalised exponent.
    @inlinable
    init(normalisedCoefficient: UInt, normalisedExponent: Int) {
        self.coefficient = normalisedCoefficient
        self.exponent = normalisedExponent
    }

    /// Normalise a given quantity into it's lowest possible representation.
    /// - Parameter quantity: The quantity to normalise.
    @inlinable
    init(quantity: ScientificQuantity) {
        guard quantity.coefficient != 0 else {
            self = .zero
            return
        }
        let rawCoefficient = quantity.coefficient
        let newExponent = quantity.exponent + rawCoefficient.trailingZeros
        let newCoefficient = rawCoefficient / UInt(pow(10.0, Double(rawCoefficient.trailingZeros)).rounded())
        self.init(normalisedCoefficient: newCoefficient, normalisedExponent: newExponent)
    }

}
