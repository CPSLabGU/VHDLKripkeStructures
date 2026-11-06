@testable import MachineTransformations
import Testing
import VHDLMachines
import VHDLParsing

/// Tests for new Arrangement extensions.
@Suite
struct ArrangementTests {
    /// test arrangement creation.
    @Test("External variable set contains variables local to the arrangement.")
    func canConstructArrangement() {
        let expected: Set<VariableName> = [.extX, .extY, .x]
        let actual = Arrangement.testArrangement.externalVariablesSet
        let difference = actual.symmetricDifference(expected)
        #expect(difference.isEmpty)
    }

    /// Test external mappings.
    @Test("External mappings contains correct mappings for instances.")
    func externalMappingsAreCorrect() throws {
        let actual = Arrangement.testArrangement.externalMappings
        #expect(actual.count == 1)
        let mapping = try #require(actual[.m0])
        #expect(mapping.count == 1)
        let yMapping = try #require(mapping[.extY])
        #expect(yMapping == .y)
    }

    /// Test reverse mappings.
    @Test("Reverse mappings contains correct mappings for instances.")
    func reverseMappingsAreCorrect() throws {
        let actual = Arrangement.testArrangement.reverseExternalMappings
        #expect(actual.count == 1)
        let mapping = try #require(actual[.m0])
        #expect(mapping.count == 1)
        let yMapping = try #require(mapping[.y])
        #expect(yMapping == .extY)
    }
}
