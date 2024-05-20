// Node.swift
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
import VHDLParsing

/// A node within a Kripke Structure.
/// 
/// A node represents a state within a kripke structure.
public final class Node: Equatable, Hashable, Codable {

    /// The type of the node.
    public let type: NodeType

    /// The state the `LLFSM` is in when the node is active.
    public let currentState: VariableName

    /// Whether the `LLFSM` executes `OnEntry` during this nodes ringlet.
    public let executeOnEntry: Bool

    /// The `nextState` variable within the `LLFSM`.
    public let nextState: VariableName

    /// The properties within the `LLFSMs` scope.
    public let properties: [VariableName: SignalLiteral]

    /// Initialise the stored properties.
    /// - Parameters:
    ///   - type: The type of the node.
    ///   - currentState: The state the `LLFSM` is in when the node is active.
    ///   - executeOnEntry: The `LLFSM` executes `OnEntry` during this nodes ringlet.
    ///   - nextState: The `nextState` variable within the `LLFSM`.
    ///   - properties: The properties within the `LLFSMs` scope.
    @inlinable
    public init(
        type: NodeType,
        currentState: VariableName,
        executeOnEntry: Bool,
        nextState: VariableName,
        properties: [VariableName: SignalLiteral]
    ) {
        self.type = type
        self.currentState = currentState
        self.executeOnEntry = executeOnEntry
        self.nextState = nextState
        self.properties = properties
    }

    /// Equality conformance.
    @inlinable
    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.type == rhs.type
            && lhs.currentState == rhs.currentState
            && lhs.executeOnEntry == rhs.executeOnEntry
            && lhs.nextState == rhs.nextState
            && lhs.properties == rhs.properties
    }

    /// Hashable conformance.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(currentState)
        hasher.combine(executeOnEntry)
        hasher.combine(nextState)
        hasher.combine(properties)
    }

}
