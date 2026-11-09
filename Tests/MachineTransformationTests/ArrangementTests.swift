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
        let expected: Set<VariableName> = [.extY, .x]
        let actual = Arrangement.testArrangement.externalVariablesSet
        let difference = actual.symmetricDifference(expected)
        #expect(difference.isEmpty)
    }

    /// Test external mappings.
    @Test("External mappings contains correct mappings for instances.")
    func externalMappingsAreCorrect() throws {
        let actual = Arrangement.testArrangement.externalMappings
        #expect(actual.count == 2)
        let mapping = try #require(actual[.m0])
        #expect(mapping.count == 2)
        let yMapping = try #require(mapping[.extY])
        #expect(yMapping == .y)
        let pulseMapping = try #require(mapping[.x])
        #expect(pulseMapping == .timerPulse)
        let timerMapping = try #require(actual[.m1])
        #expect(timerMapping.count == 1)
        let xMapping = try #require(timerMapping[.x])
        #expect(xMapping == .pulse)
    }

    /// Test reverse mappings.
    @Test("Reverse mappings contains correct mappings for instances.")
    func reverseMappingsAreCorrect() throws {
        let actual = Arrangement.testArrangement.reverseExternalMappings
        #expect(actual.count == 2)
        let mapping = try #require(actual[.m0])
        #expect(mapping.count == 2)
        let yMapping = try #require(mapping[.y])
        #expect(yMapping == .extY)
        let pulseMapping = try #require(mapping[.timerPulse])
        #expect(pulseMapping == .x)
        let timerMapping = try #require(actual[.m1])
        #expect(timerMapping.count == 1)
        let xMapping = try #require(timerMapping[.pulse])
        #expect(xMapping == .x)
    }
}
