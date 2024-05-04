import Foundation

// don't care about implementation as could be ASCII or something else.  Use extensions to handle UI of renderer but have protocol such that we can attach to particles.
public protocol ParticleRenderer {
    associatedtype Configuration: ParticleConfiguration
    // give each particle a potentially different configuration
    func newParticle(x: Double, y: Double) -> Particle<Configuration>
    /// Update the particle position and configuration using the behavior.  Return `false` if the particle should be removed and no longer updated.
    func update(particle: inout Particle<Configuration>, date: TimeInterval) -> Bool
}
