// NodeTests.swift
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
import Testing

/// Test class for ``Node``.
@Suite
struct NodeTests {

    /// Some test properties.
    let properties: [VariableName: SignalLiteral] = [
        .x: .bit(value: .low),
        .y: .logic(value: .highImpedance),
        .z: .integer(value: 30),
    ]

    /// A test node.
    var node: Node {
        Node(
            type: .read,
            currentState: .initial,
            executeOnEntry: true,
            nextState: .suspended,
            properties: properties
        )
    }

    /// Test that the init sets the stored properties correctly.
    @Test
    func testInit() {
        #expect(node.type == .read)
        #expect(node.currentState == .initial)
        #expect(node.executeOnEntry)
        #expect(node.nextState == .suspended)
        #expect(node.properties == properties)
    }

    /// Test equality conformance.
    @Test
    func testEquality() {
        let otherNode = Node(
            type: .read,
            currentState: .initial,
            executeOnEntry: true,
            nextState: .suspended,
            properties: properties
        )
        #expect(node == otherNode)
    }

    /// Test hashable conformance.
    @Test
    func testHashable() {
        let otherNode = Node(
            type: .read,
            currentState: .initial,
            executeOnEntry: true,
            nextState: .suspended,
            properties: properties
        )
        #expect(node.hashValue == otherNode.hashValue)
        let nodes: Set<Node> = [node]
        #expect(nodes.contains(otherNode))
    }

    /// Test graphviz representation.
    @Test
    func testGraphvizRepresentation() {
        // swiftlint:disable line_length
        let expected = """
            {\\ «Read»\\nInitial | executeOnEntry: true,\\lnextState: Suspended,\\lx: '0',\\ly: 'Z',\\lz: 30\\l}
            """
        // swiftlint:enable line_length
        #expect(node.graphviz == expected)
        let node2 = Node(
            type: node.type,
            currentState: node.currentState,
            executeOnEntry: node.executeOnEntry,
            nextState: node.nextState,
            properties: [:]
        )
        let expected2 = """
            {\\ «Read»\\nInitial | executeOnEntry: true,\\lnextState: Suspended\\l}
            """
        #expect(node2.graphviz == expected2)
    }

    @Test
    func testDescription() {
        let expected = """
            Node(
                currentState: Initial,
                type: read,
                executeOnEntry: true,
                nextState: Suspended,
                properties:
                    x: '0',
                    y: 'Z',
                    z: 30
            )
            """
        #expect(node.description == expected)
    }

}
