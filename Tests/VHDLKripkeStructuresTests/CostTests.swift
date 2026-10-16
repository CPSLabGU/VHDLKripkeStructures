// CostTests.swift
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

/// Test class for ``Cost``.
@Suite
struct CostTests {

    /// A time value.
    let time = ScientificQuantity(coefficient: 2, exponent: -6)

    /// An energy value.
    let energy = ScientificQuantity(coefficient: 1, exponent: -3)

    /// A cost.
    let cost1 = Cost(
        time: ScientificQuantity(coefficient: 1, exponent: 2),
        energy: ScientificQuantity(coefficient: 1, exponent: 1)
    )

    /// A second cost.
    let cost2 = Cost(
        time: ScientificQuantity(coefficient: 1, exponent: 1),
        energy: ScientificQuantity(coefficient: 1, exponent: 0)
    )

    /// A test `Cost`.
    var cost: Cost {
        Cost(time: time, energy: energy)
    }

    /// Test that `init` sets the stored properties correctly.
    @Test
    func testInit() {
        #expect(cost.time == time)
        #expect(cost.energy == energy)
    }

    /// Test `zero`.
    @Test
    func testZero() {
        #expect(Cost(time: .zero, energy: .zero) == .zero)
    }

    /// Test addition.
    @Test
    func testAddition() {
        #expect(
            cost1 + cost2
                == Cost(
                    time: ScientificQuantity(coefficient: 11, exponent: 1),
                    energy: ScientificQuantity(coefficient: 11, exponent: 0)
                )
        )
    }

    /// Test subtraction.
    @Test
    func testSubtraction() {
        #expect(
            cost1 - cost2
                == Cost(
                    time: ScientificQuantity(coefficient: 9, exponent: 1),
                    energy: ScientificQuantity(coefficient: 9, exponent: 0)
                )
        )
    }

    /// Test graphivz convertible conformance.
    @Test
    func testGraphvizRepresentation() {
        #expect(cost1.graphviz == "\"t: 100 s, E: 10 J\"")
    }

}
