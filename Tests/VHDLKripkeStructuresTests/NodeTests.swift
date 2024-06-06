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
import XCTest

/// Test class for ``Node``.
final class NodeTests: XCTestCase {

    /// Some test properties.
    let properties: [VariableName: SignalLiteral] = [
        .x: .bit(value: .low),
        .y: .logic(value: .highImpedance),
        .z: .integer(value: 30)
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
    func testInit() {
        XCTAssertEqual(node.type, .read)
        XCTAssertEqual(node.currentState, .initial)
        XCTAssertTrue(node.executeOnEntry)
        XCTAssertEqual(node.nextState, .suspended)
        XCTAssertEqual(node.properties, properties)
    }

    /// Test equality conformance.
    func testEquality() {
        let otherNode = Node(
            type: .read,
            currentState: .initial,
            executeOnEntry: true,
            nextState: .suspended,
            properties: properties
        )
        XCTAssertEqual(node, otherNode)
    }

    /// Test hashable conformance.
    func testHashable() {
        let otherNode = Node(
            type: .read,
            currentState: .initial,
            executeOnEntry: true,
            nextState: .suspended,
            properties: properties
        )
        XCTAssertEqual(node.hashValue, otherNode.hashValue)
        let nodes: Set<Node> = [node]
        XCTAssertTrue(nodes.contains(otherNode))
    }

    /// Test graphviz representation.
    func testGraphvizRepresentation() {
        let expected = """
        \\ «Read»
        \\ Initial
        \\ executeOnEntry: true,
        \\ nextState: Suspended,
        \\ x: '0',
        \\ y: 'Z',
        \\ z: 30
        """
        XCTAssertEqual(node.graphviz, expected)
        let node2 = Node(
            type: node.type,
            currentState: node.currentState,
            executeOnEntry: node.executeOnEntry,
            nextState: node.nextState,
            properties: [:]
        )
        let expected2 = """
        \\ «Read»
        \\ Initial
        \\ executeOnEntry: true,
        \\ nextState: Suspended
        """
        XCTAssertEqual(node2.graphviz, expected2)
    }

}
