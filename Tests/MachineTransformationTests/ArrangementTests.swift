import Testing
import VHDLMachines

/// Tests for new Arrangement extensions.
@Suite
struct ArrangementTests {
    /// test arrangement creation.
    @Test
    func canConstructArrangement() {
        #expect(Arrangement.testArrangement != nil)
    }
}
