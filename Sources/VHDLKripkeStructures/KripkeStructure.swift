// KripkeStructure.swift
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

/// A Kripke Structure.
///
/// A Kripke structure represents a complete graph of possible states an `LLFSM` can be in. Each `Node`
/// represents a collection of all variables and their respective values at different points in time during
/// the `LLFSM` computation. Each `Edge` represents a transition between two `Node`s.
public class KripkeStructure: Equatable, Hashable, Codable {

    /// The nodes in the kripke structure.
    public let nodes: [Node]

    /// The edges between the nodes.
    public let edges: [Node: [Edge]]

    /// The starting nodes in the structure. These nodes are the default nodes that the `LLFSM` starts in.
    public let initialStates: Set<Node>

    /// Initialise the structure from it's stored properties.
    /// - Parameters:
    ///  - nodes: The nodes in the kripke structure.
    ///  - edges: The edges between the nodes.
    ///  - initialStates: The starting nodes in the structure.
    @inlinable
    public init(nodes: [Node], edges: [Node: [Edge]], initialStates: Set<Node>) {
        self.nodes = nodes
        self.edges = edges
        self.initialStates = initialStates
    }

    /// Equality conformance.
    @inlinable
    public static func == (lhs: KripkeStructure, rhs: KripkeStructure) -> Bool {
        lhs.nodes == rhs.nodes && lhs.edges == rhs.edges && lhs.initialStates == rhs.initialStates
    }

    /// Hashable conformance.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(nodes)
        hasher.combine(edges)
        hasher.combine(initialStates)
    }

}
