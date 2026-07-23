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
import Testing

/// Bridges ParticleEffects' ordered reusable tests into Swift Testing.
///
/// Animation timing and SwiftUI layout remain excluded because wall-clock and view-hosting checks would be
/// fragile across the package's supported platforms. The deterministic checks live on ``ParticleEffects/tests``.
@Suite("ParticleEffects Tests")
struct ParticleEffectsTests {
    /// Runs one shared test while retaining its section name in Swift Testing's argument report.
    @Test(
        "Reusable ParticleEffects test",
        .serialized,
        arguments: await MainActor.run {
            ParticleEffects.tests.flatMap { section, tests in
                tests.map { (section: section, test: $0) }
            }
        }
    )
    @MainActor
    @available(iOS 13, macOS 12, tvOS 13, watchOS 6, *)
    func reusableParticleEffectsTest(section: String, test: TestCase) async throws {
        // The section is intentionally retained as an argument so failures are grouped in deterministic context.
        _ = section
        // Execute the shared closure directly so thrown failures remain native Swift Testing failures.
        try await test.execute()
    }
}
#endif
