//
//  ParticleEffectsTests.swift
//  ParticleEffectsTests
//
//  Created by Ben Ku on 7/13/26.
//

// Swift Testing requires Swift 5.9 or newer. These guards also keep alternate toolchains from trying to
// compile an unavailable test framework or module while the manifest's separate guard protects Playgrounds.
#if compiler(>=5.9) && canImport(ParticleEffects) && canImport(Testing)
import ParticleEffects
import Testing

/// Regression coverage for deterministic model and renderer-support behavior.
///
/// Animation timing and SwiftUI layout are deliberately excluded because wall-clock and view-hosting tests
/// would be fragile across the many Apple platforms supported by ParticleEffects.
@Suite("ParticleEffects model behavior")
struct ParticleEffectsTests {
    /// Verifies the public version stays aligned with the package and changelog release surfaces.
    @Test("Published version")
    func publishedVersion() {
        #expect(ParticleEffects.version.description == "2.0.2")
    }

    /// Confirms comma-separated renderer content cycles predictably using a particle's stable creation index.
    @Test("Particle content cycles by stable index")
    func particleContentCyclesByStableIndex() {
        let content: ParticleContent = "spark,star,flare"
        let particle = Particle(index: 4, initialPosition: .zero, initialVelocity: .zero)
        let state = ParticleState(particle: particle, position: .zero, opacity: 1, blur: .none)

        // Index four wraps to the second item, proving renderers can choose content without storing UI data
        // in the particle model itself.
        #expect(content.value(for: state) == "star")
    }

    /// Protects the documented fire-coloring curve at its start, midpoint boundary, and completed lifetime.
    @Test("Fire coloring helpers remain bounded")
    func fireColoringHelpersRemainBounded() {
        #expect(ParticleState.fireSaturation(for: 0) == 0.1)
        #expect(ParticleState.fireHue(for: 0.5) == 0.16)
        #expect(ParticleState.fireHue(for: 1) == 0)
    }

    /// Ensures named behavior values remain available to custom renderers without expanding core state.
    @Test("Named state values are retrievable")
    func namedStateValuesAreRetrievable() {
        let particle = Particle(index: 0, initialPosition: .zero, initialVelocity: .zero)
        let state = ParticleState(
            particle: particle,
            position: .zero,
            opacity: 1,
            blur: .none,
            values: ["glow": 0.75]
        )

        #expect(state.value(named: "glow") == 0.75)
        #expect(state.value(named: "missing") == nil)
    }
}
#endif
