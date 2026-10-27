// ScientificQuantityTests.swift
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

import Testing
@testable import VHDLKripkeStructures

/// Test class for ``ScientificQuantity``.
@Suite
struct ScientificQuantityTests {

    /// The quantity to test.
    let quantity = ScientificQuantity(coefficient: 2, exponent: 3)

    /// Another quantity to test.
    let quantity2 = ScientificQuantity(coefficient: 4, exponent: 5)

    /// A third quantity to test.
    let quantity3 = ScientificQuantity(coefficient: 2, exponent: -2)

    /// A fourth quantity to test.
    let quantity4 = ScientificQuantity(coefficient: 5, exponent: -3)

    /// Test that the stored properties are set correctly.
    @Test
    func testInit() {
        #expect(quantity.coefficient == 2)
        #expect(quantity.exponent == 3)
    }

    /// Test that the SI init works.
    @Test
    func testSIInit() {
        #expect(ScientificQuantity(SIValue: quantity) == quantity)
    }

    /// Test that the quantity is calculated correctly.
    @Test
    func testQuantity() {
        #expect(quantity.quantity == 2000.0)
    }

    /// Test that the magnitude is correct.
    @Test
    func testMagnitude() {
        #expect(quantity.magnitude == 2000.0)
    }

    /// Test integer literal creation.
    @Test
    func testIntegerLiteral() {
        #expect(500 == ScientificQuantity(coefficient: 5, exponent: 2))
        #expect(501 == ScientificQuantity(coefficient: 501, exponent: 0))
        #expect(560 == ScientificQuantity(coefficient: 56, exponent: 1))
        #expect(0 == ScientificQuantity.zero)
    }

    /// Test exactly init.
    @Test
    func testExactly() {
        #expect(ScientificQuantity(exactly: 500) == ScientificQuantity(coefficient: 5, exponent: 2))
        #expect(ScientificQuantity(exactly: 501) == ScientificQuantity(coefficient: 501, exponent: 0))
        #expect(ScientificQuantity(exactly: 560) == ScientificQuantity(coefficient: 56, exponent: 1))
        #expect(ScientificQuantity(exactly: 0) == ScientificQuantity.zero)
        #expect(ScientificQuantity(exactly: -1) == nil)
    }

    /// Test the quantity init.
    @Test
    func testQuantityInit() {
        #expect(
            ScientificQuantity(quantity: ScientificQuantity(coefficient: 20, exponent: 2)) == quantity
        )
        #expect(
            ScientificQuantity(quantity: ScientificQuantity(coefficient: 200, exponent: 1)) == quantity
        )
        #expect(
            ScientificQuantity(quantity: ScientificQuantity(coefficient: 2000, exponent: 0)) == quantity
        )
        #expect(ScientificQuantity(quantity: quantity) == quantity)
    }

    /// Test that the description is correct.
    @Test
    func testDescription() {
        #expect(quantity.description == "2×10³")
        #expect(quantity2.description == "4×10⁵")
        #expect(ScientificQuantity.zero.description == "0")
        #expect(ScientificQuantity(coefficient: 1, exponent: -2).description == "1×10⁻²")
    }

    /// Test that addition works correctly.
    @Test
    func testAddition() {
        #expect(quantity + quantity2 == ScientificQuantity(coefficient: 402, exponent: 3))
        #expect(quantity2 + quantity == ScientificQuantity(coefficient: 402, exponent: 3))
        #expect(quantity2 + quantity2 == ScientificQuantity(coefficient: 8, exponent: 5))
        #expect(
            quantity + ScientificQuantity(coefficient: 20, exponent: 2)
                == ScientificQuantity(coefficient: 4, exponent: 3)
        )
        #expect(quantity + quantity3 == ScientificQuantity(coefficient: 200002, exponent: -2))
        #expect(quantity3 + quantity == ScientificQuantity(coefficient: 200002, exponent: -2))
        #expect(quantity4 + quantity3 == ScientificQuantity(coefficient: 25, exponent: -3))
        #expect(quantity3 + quantity4 == ScientificQuantity(coefficient: 25, exponent: -3))
    }

    /// Test subtraction.
    @Test
    func testSubtraction() {
        #expect(quantity2 - quantity == ScientificQuantity(coefficient: 398, exponent: 3))
        #expect(quantity - ScientificQuantity(coefficient: 20, exponent: 2) == .zero)
        #expect(quantity - quantity3 == ScientificQuantity(coefficient: 199998, exponent: -2))
        #expect(quantity3 - quantity4 == ScientificQuantity(coefficient: 15, exponent: -3))
    }

    /// Test multiplication.
    @Test
    func testMultiplication() {
        #expect(quantity * quantity2 == ScientificQuantity(coefficient: 8, exponent: 8))
        #expect(quantity2 * quantity == ScientificQuantity(coefficient: 8, exponent: 8))
        #expect(quantity2 * quantity2 == ScientificQuantity(coefficient: 16, exponent: 10))
        #expect(quantity * quantity3 == ScientificQuantity(coefficient: 4, exponent: 1))
        #expect(quantity3 * quantity == ScientificQuantity(coefficient: 4, exponent: 1))
        #expect(quantity4 * quantity3 == ScientificQuantity(coefficient: 1, exponent: -4))
        #expect(quantity3 * quantity4 == ScientificQuantity(coefficient: 1, exponent: -4))
        #expect(quantity * .zero == .zero)
        #expect(quantity3 * .zero == .zero)
        #expect(quantity4 * .zero == .zero)
        #expect(.zero * quantity == .zero)
        #expect(.zero * quantity3 == .zero)
        #expect(.zero * quantity4 == .zero)
    }

    /// Test `*=`.
    @Test
    func testMutatingMultiply() {
        var quantity = quantity
        quantity *= quantity2
        #expect(quantity == ScientificQuantity(coefficient: 8, exponent: 8))
    }

    /// Test uint trailing zeros.
    @Test
    func testUIntTrailingZeros() {
        #expect(UInt(500).trailingZeros == 2)
        #expect(UInt(501).trailingZeros == 0)
        #expect(UInt(560).trailingZeros == 1)
        #expect(UInt(0).trailingZeros == 0)
    }

    /// Test float creation.
    @Test
    func testFloatCreation() {
        #expect(2000.0 == quantity)
        #expect(400000.0 == quantity2)
        #expect(0.02 == quantity3)
        #expect(0.005 == quantity4)
        #expect(0.0 == ScientificQuantity.zero)
        let value = Double(2000.0)
        #expect(ScientificQuantity(floatLiteral: value) == quantity)
    }

    /// Test `siValue` computes the correct value.
    @Test
    func testSIValuePositive() {
        #expect(
            ScientificQuantity(coefficient: 0, exponent: 5).siValue
                == UnnormalisedScientificQuantity(coefficient: 0, exponent: 0)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 0).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: 0)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 1).siValue
                == UnnormalisedScientificQuantity(coefficient: 20, exponent: 0)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 2).siValue
                == UnnormalisedScientificQuantity(coefficient: 200, exponent: 0)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 3).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: 3)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 4).siValue
                == UnnormalisedScientificQuantity(coefficient: 20, exponent: 3)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 5).siValue
                == UnnormalisedScientificQuantity(coefficient: 200, exponent: 3)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 6).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: 6)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 7).siValue
                == UnnormalisedScientificQuantity(coefficient: 20, exponent: 6)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: 0).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: 0)
        )
    }

    /// Test negative exponents of `siValue` property.
    @Test
    func testSIValueNegative() {
        #expect(
            ScientificQuantity(coefficient: 0, exponent: -5).siValue
                == UnnormalisedScientificQuantity(coefficient: 0, exponent: 0)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -1).siValue
                == UnnormalisedScientificQuantity(coefficient: 200, exponent: -3)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -2).siValue
                == UnnormalisedScientificQuantity(coefficient: 20, exponent: -3)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -3).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: -3)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -4).siValue
                == UnnormalisedScientificQuantity(coefficient: 200, exponent: -6)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -5).siValue
                == UnnormalisedScientificQuantity(coefficient: 20, exponent: -6)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -6).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: -6)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -7).siValue
                == UnnormalisedScientificQuantity(coefficient: 200, exponent: -9)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -8).siValue
                == UnnormalisedScientificQuantity(coefficient: 20, exponent: -9)
        )
        #expect(
            ScientificQuantity(coefficient: 2, exponent: -9).siValue
                == UnnormalisedScientificQuantity(coefficient: 2, exponent: -9)
        )
    }

    /// Test `Comparable` conformance.
    @Test
    func testComparable() {
        #expect(
            ScientificQuantity(coefficient: 1, exponent: 2) < ScientificQuantity(coefficient: 2, exponent: 2)
        )
        #expect(
            // swiftlint:disable:next identical_operands
            !(ScientificQuantity(coefficient: 1, exponent: 2)
                < ScientificQuantity(coefficient: 1, exponent: 2))
        )
        #expect(
            ScientificQuantity(coefficient: 1, exponent: 2) < ScientificQuantity(coefficient: 1, exponent: 3)
        )
        #expect(
            ScientificQuantity(coefficient: 10, exponent: 2) < ScientificQuantity(coefficient: 2, exponent: 3)
        )
        #expect(
            !(ScientificQuantity(coefficient: 20, exponent: 2)
                < ScientificQuantity(coefficient: 1, exponent: 3))
        )
        #expect(
            ScientificQuantity(coefficient: 0, exponent: 2) < ScientificQuantity(coefficient: 2, exponent: -3)
        )
    }

}
