//
//  ParticleEffectsTests.swift
//  ParticleEffectsTests
//
//  Created by Ben Ku on 7/13/26.
//

// Swift Testing requires Swift 5.9 or newer. These guards also keep alternate toolchains from trying to
// compile an unavailable test framework or module while the manifest's separate guard protects Playgrounds.
#if compiler(>=5.9) && canImport(ParticleEffects) && canImport(Testing)
import Compatibility
import ParticleEffects
import CompatibilityTesting
import Testing

/// Bridges ParticleEffects' ordered reusable tests into individually reported Swift Testing cases.
///
/// Animation timing and SwiftUI layout remain excluded because wall-clock and view-hosting checks would be
/// fragile across the package's supported platforms. The deterministic checks live on ``ParticleEffects/tests``.
@Suite("ParticleEffects Tests")
struct ParticleEffectsTests {
    /// Runs one shared test while retaining its section name in Swift Testing's argument report.
    @Test(
        "Reusable ParticleEffects test",
        .serialized,
        arguments: await ParticleEffects.testEntries()
    )
    @MainActor
    @available(iOS 13, macOS 12, tvOS 13, watchOS 6, *)
    func reusableParticleEffectsTest(entry: ModuleTestEntry) async throws {
        // Execute the shared closure through the adapter so each catalog entry has a stable identity.
        try await entry.execute()
    }
}
#endif
