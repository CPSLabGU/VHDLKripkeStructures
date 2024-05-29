// KripkeStructureTests.swift
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
import VHDLParsing
import XCTest

/// Test class for ``KripkeStructure``.
final class KripkeStructureTests: XCTestCase {

    /// Some test properties.
    let properties1: [VariableName: SignalLiteral] = [
        .x: .bit(value: .low),
        .y: .logic(value: .highImpedance),
        .z: .integer(value: 30)
    ]

    /// Some more test properties.
    let properties2: [VariableName: SignalLiteral] = [
        .x: .bit(value: .high),
        .y: .logic(value: .low),
        .z: .integer(value: 20)
    ]

    /// A test node.
    var node1: Node {
        Node(
            type: .read,
            currentState: .initial,
            executeOnEntry: true,
            nextState: .suspended,
            properties: properties1
        )
    }

    /// Another test node.
    var node2: Node {
        Node(
            type: .write,
            currentState: .suspended,
            executeOnEntry: false,
            nextState: .initial,
            properties: properties2
        )
    }

    /// The edges between the nodes.
    var edges: [Node: [Edge]] {
        [
            node1: [
                Edge(
                    target: node2,
                    cost: Cost(
                        time: ScientificQuantity(coefficient: 1, exponent: 2),
                        energy: ScientificQuantity(coefficient: 2, exponent: 2)
                    )
                )
            ],
            node2: [
                Edge(
                    target: node1,
                    cost: Cost(
                        time: ScientificQuantity(coefficient: 3, exponent: 1),
                        energy: ScientificQuantity(coefficient: 4, exponent: 1)
                    )
                )
            ]
        ]
    }

    /// A test kripke structure.
    var structure: KripkeStructure {
        KripkeStructure(nodes: [node1, node2], edges: edges, initialStates: [node1])
    }

    /// Test that the init sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(structure.nodes, [node1, node2])
        XCTAssertEqual(structure.edges, edges)
        XCTAssertEqual(structure.initialStates, [node1])
    }

    /// Test equality conformance.
    func testEquality() {
        let otherStructure = KripkeStructure(nodes: [node1, node2], edges: edges, initialStates: [node1])
        XCTAssertEqual(structure, otherStructure)
    }

    /// Test hashable conformance.
    func testHashable() {
        let otherStructure = KripkeStructure(nodes: [node1, node2], edges: edges, initialStates: [node1])
        XCTAssertEqual(structure.hashValue, otherStructure.hashValue)
        let structures: Set<KripkeStructure> = [structure]
        XCTAssertTrue(structures.contains(otherStructure))
    }

    /// Test the graphviz representation.
    func testGraphvizRepresentation() {
        let expected = """
        digraph {
            \"0\" [style=rounded shape=rectangle label=\"\\ currentState: Initial,
            \\ type: read,
            \\ executeOnEntry: true,
            \\ nextState: Suspended,
            \\ x: '0',
            \\ y: 'Z',
            \\ z: 30\"]
            \"1\" [style=rounded shape=rectangle label=\"\\ currentState: Suspended,
            \\ type: write,
            \\ executeOnEntry: false,
            \\ nextState: Initial,
            \\ x: '1',
            \\ y: '0',
            \\ z: 20\"]
            \"0\" -> \"1\" [label=\"t: 1e+2, E: 2e+2\"]
            \"1\" -> \"0\" [label=\"t: 3e+1, E: 4e+1\"]
        }
        """
        XCTAssertEqual(structure.graphviz, expected, "\(structure.graphviz.difference(from: expected))")
    }

}
