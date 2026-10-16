// UnnormalisedScientificQuantityTests.swift
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

@testable import VHDLKripkeStructures
import Testing

/// Test class for ``UnnormalisedScientificQuantity``.
@Suite
struct UnnormalisedScientificQuantityTests {

    /// Test init sets stored properties correctly.
    @Test
    func testInit() {
        let value = UnnormalisedScientificQuantity(coefficient: 20, exponent: 3)
        #expect(value.coefficient == 20)
        #expect(value.exponent == 3)
    }

    /// Test conversion from normalised form.
    @Test
    func testNormalisedInit() {
        let value = ScientificQuantity(coefficient: 200, exponent: 0)
        let unnormalised = UnnormalisedScientificQuantity(quantity: value)
        #expect(unnormalised.coefficient == 2)
        #expect(unnormalised.exponent == 2)
    }

    /// Test time string.
    @Test
    func testTimeStr() {
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: 0).timeStr == "2 s")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -3).timeStr == "2 ms")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -6).timeStr == "2 μs")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -9).timeStr == "2 ns")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -12).timeStr == "2 ps")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -15).timeStr == "2 fs")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -2).timeStr == "2×10⁻² s")
    }

    /// Test energy string.
    @Test
    func testEnergyStr() {
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: 12).energyStr == "2 TJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: 9).energyStr == "2 GJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: 6).energyStr == "2 MJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: 3).energyStr == "2 kJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: 0).energyStr == "2 J")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -3).energyStr == "2 mJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -6).energyStr == "2 μJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -9).energyStr == "2 nJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -12).energyStr == "2 pJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -15).energyStr == "2 fJ")
        #expect(UnnormalisedScientificQuantity(coefficient: 2, exponent: -2).energyStr == "2×10⁻² J")
    }

}
