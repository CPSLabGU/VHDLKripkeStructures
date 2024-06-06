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
import XCTest

/// Test class for ``UnnormalisedScientificQuantity``.
final class UnnormalisedScientificQuantityTests: XCTestCase {

    /// Test init sets stored properties correctly.
    func testInit() {
        let value = UnnormalisedScientificQuantity(coefficient: 20, exponent: 3)
        XCTAssertEqual(value.coefficient, 20)
        XCTAssertEqual(value.exponent, 3)
    }

    /// Test conversion from normalised form.
    func testNormalisedInit() {
        let value = ScientificQuantity(coefficient: 200, exponent: 0)
        let unnormalised = UnnormalisedScientificQuantity(quantity: value)
        XCTAssertEqual(unnormalised.coefficient, 2)
        XCTAssertEqual(unnormalised.exponent, 2)
    }

    /// Test time string.
    func testTimeStr() {
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: 0).timeStr, "2 s")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -3).timeStr, "2 ms")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -6).timeStr, "2 μs")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -9).timeStr, "2 ns")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -12).timeStr, "2 ps")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -15).timeStr, "2 fs")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -2).timeStr, "2×10⁻² s")
    }

    /// Test energy string.
    func testEnergyStr() {
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: 12).energyStr, "2 TJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: 9).energyStr, "2 GJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: 6).energyStr, "2 MJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: 3).energyStr, "2 kJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: 0).energyStr, "2 J")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -3).energyStr, "2 mJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -6).energyStr, "2 μJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -9).energyStr, "2 nJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -12).energyStr, "2 pJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -15).energyStr, "2 fJ")
        XCTAssertEqual(UnnormalisedScientificQuantity(coefficient: 2, exponent: -2).energyStr, "2×10⁻² J")
    }

}
