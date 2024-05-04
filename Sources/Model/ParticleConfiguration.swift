import Foundation

public protocol ParticleConfiguration: Hashable {
    mutating func update(particle: Particle<Self>, behavior: ParticleBehavior, at: TimeInterval)
}
