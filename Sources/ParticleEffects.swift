//
//  ParticleEffects.swift
//  
//
//  Created by Ben Ku on 5/13/24.
//  Copyright © 2024-2026 Kudit, LLC. All rights reserved.
//

import Compatibility

/// ParticleEffects package metadata and reusable tests.
///
/// `ParticleEffects` conforms to Compatibility's ``Module`` protocol so applications can include the
/// package in version, dependency, support, and test reports. Register this highest-level module once during
/// application startup with `Application.track(including: [ParticleEffects.self])`; Compatibility is then
/// discovered automatically through ``dependencies``.
public struct ParticleEffects: Module {
    /// The version of the ParticleEffects Library.
    ///
    /// Swift packages cannot read their manifest version at runtime, so this value stays synchronized with
    /// `Package.swift`, the changelog, the development project, tests, and README release examples.
    public static let version: Version = "2.0.5"

    /// Modules used directly by ParticleEffects.
    ///
    /// Compatibility provides the shared module metadata, diagnostics, and testing APIs used by this package.
    public static let dependencies: [Module.Type] = [Compatibility.self]

    /// Immediately available ParticleEffects module information.
    ///
    /// ParticleEffects currently has no package-specific diagnostic fields beyond the version appended by
    /// Compatibility, so this collection is intentionally empty and remains portable across supported targets.
    public static let moduleInfo: [Field] = []

    /// Public source repository used for source discovery and opt-in license reporting.
    public static let openSourceRepository: String? = "https://github.com/kudit/ParticleEffects"

#if compiler(>=5.9)
    /// Reusable ParticleEffects tests grouped in deterministic display and execution order.
    ///
    /// Compatibility's in-app module test UI and the Swift Testing bridge both execute these same
    /// ``TestCase`` instances so assertions remain authored in one place.
    @MainActor
    @available(iOS 13, macOS 12, tvOS 13, watchOS 6, *)
    public static var tests: OrderedDictionary<String, [TestCase]> {
        // Keep metadata checks first because they quickly identify an incorrectly integrated package release.
        var sections: OrderedDictionary<String, [TestCase]> = [
            "Module Metadata": [
                TestCase("Module metadata describes ParticleEffects") {
                    try expect(
                        ParticleEffects.dependencies.contains {
                            $0.moduleIdentifier == Compatibility.moduleIdentifier
                        },
                        "Expected Compatibility to be a direct module dependency"
                    )
                    try expectEqual(
                        ParticleEffects.openSourceRepository,
                        "https://github.com/kudit/ParticleEffects",
                        "Expected the public repository metadata"
                    )
                    try expect(
                        ParticleEffects.moduleInfo.isEmpty,
                        "ParticleEffects does not provide package-specific immediate module information"
                    )
                },
            ],
            "Particle Model": [
                TestCase("Fire coloring helpers remain bounded") {
                    try expectEqual(ParticleState.fireSaturation(for: 0), 0.1)
                    try expectEqual(ParticleState.fireHue(for: 0.5), 0.16)
                    try expectEqual(ParticleState.fireHue(for: 1), 0)
                },
                TestCase("Named state values are retrievable") {
                    let particle = Particle(index: 0, initialPosition: .zero, initialVelocity: .zero)
                    let state = ParticleState(
                        particle: particle,
                        position: .zero,
                        opacity: 1,
                        blur: .none,
                        values: ["glow": 0.75]
                    )

                    try expectEqual(state.value(named: "glow"), 0.75)
                    try expect(state.value(named: "missing") == nil, "Expected an unknown named value to be absent")
                },
                TestCase("Particle content handles empty and negative indexes") {
                    let empty = ParticleContent("")
                    let negative = Particle(index: -1, initialPosition: .zero, initialVelocity: .zero)
                    let negativeState = ParticleState(particle: negative, position: .zero, opacity: 1, blur: .none)
                    try expectEqual(empty.value(for: negativeState), "")

                    let content = ParticleContent("one,two,three")
                    let state = ParticleState(
                        particle: Particle(index: -1, initialPosition: .zero, initialVelocity: .zero),
                        position: .zero,
                        opacity: 1,
                        blur: .none
                    )
                    // Modulo cycling should wrap negative identities to the final content value.
                    try expectEqual(content.value(for: state), "three")
                },
                TestCase("Particle content handles large indexes") {
                    let content = ParticleContent("one,two,three")
                    let particle = Particle(index: Int.max, initialPosition: .zero, initialVelocity: .zero)
                    let state = ParticleState(particle: particle, position: .zero, opacity: 1, blur: .none)
                    try expectEqual(content.value(for: state), "two")
                },
                TestCase("Particle state exposes calculated motion and lifetime") {
                    let behavior = ParticleBehavior(
                        lifetime: 2,
                        fadeOut: 0.5,
                        initialVelocity: 10,
                        acceleration: .none
                    )
                    let particle = Particle(index: 0, initialPosition: .zero, initialVelocity: Vector(x: 1, y: 0))
                    let currentTime = particle.creationDate + 1
                    let state = behavior.currentState(for: particle, at: currentTime)
                    try expectEqual(state.lifetimeAge, 0.5)
                    try expectEqual(state.position.x, 1)
                    try expectEqual(state.position.y, 0)
                    try expectEqual(state.opacity, 1)
                    try expect(!behavior.shouldRemove(particle: particle, at: currentTime))
                    try expect(behavior.shouldRemove(particle: particle, at: particle.creationDate + 2.01))
                },
                TestCase("Particle behavior creates particles only after its birth interval") {
                    let behavior = ParticleBehavior(birthRate: 1, spread: .none, initialVelocity: 2)
                    try expect(behavior.newParticle(initialPosition: .zero, timeSinceLastGeneration: 1, particleCount: 4) == nil)
                    let particle = behavior.newParticle(initialPosition: .zero, timeSinceLastGeneration: 1.01, particleCount: 4)
                    try expectEqual(particle?.index, 4)
                    try expectEqual(particle?.initialPosition, .zero)
                },
            ],
        ]

#if canImport(SwiftUI)
        // Renderer content exists only on SwiftUI targets, while the model sections remain portable elsewhere.
        sections["Renderer Content"] = [
            TestCase("Particle content cycles by stable index") {
                let content: ParticleContent = "spark,star,flare"
                let particle = Particle(index: 4, initialPosition: .zero, initialVelocity: .zero)
                let state = ParticleState(particle: particle, position: .zero, opacity: 1, blur: .none)

                try expectEqual(content.value(for: state), "star")
            },
        ]
#endif

        return sections
    }
#endif
}
