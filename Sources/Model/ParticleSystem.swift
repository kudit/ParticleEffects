#if canImport(SwiftUI)
import SwiftUI

public extension UnitPoint {
    var vector: Vector {
        return Vector(x: self.x, y: self.y)
    }
}

/// For Type Erasure and observation
@MainActor
public class ParticleSystem: ObservableObject {
    @Published public var particles = [Particle]()
    /// Where emissions happen from
    @Published public var center = UnitPoint.center
    @Published public var behavior: ParticleBehavior
    @Published public var lastParticleCreation: TimeInterval = .zero
    @Published public var particleCounter = 0

    private var timer: Timer? = nil
    public init(center: UnitPoint = .center, behavior: ParticleBehavior = .default) {
        self.center = center
        self.behavior = behavior
        timer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            // check for new births
            // remove dead particles
            Task { @MainActor in // TODO: Make mini KuditFramework with things like debug and threading and various string functions for inclusion here.
                self.update(at: Date.timeIntervalSinceReferenceDate)
            }
        }
    }
    deinit {
        timer?.invalidate()
    }
    
    public func particles(for currentTime: TimeInterval) -> [ParticleState] {
        return particles.map { behavior.currentState(for: $0, at: currentTime) }
    }
    
    // TODO: Move additionalConfiguration to an optional additional function on the particle system.
    /// Generate new particle and update existing particles based on behavior.
    public func update(at currentTime: TimeInterval) {
        particles.filtered { particle in
            !behavior.shouldRemove(particle: particle, at: currentTime)
        }
        
        // pass in the time so we know how frequent to generate...store last time so that this isn't framerate dependent
        if let newParticle = behavior.newParticle(initialPosition: center.vector, timeSinceLastGeneration: currentTime - lastParticleCreation, particleCount: particleCounter) {
            particles.append(newParticle)
            // update last update and count
            lastParticleCreation = currentTime
            particleCounter += 1
        }
    }
}
/*
 var intensity: Intensity = .medium
 
 // emitter layer config parameters
 var emitterPosition: EmitterPosition = .top
 var clipsToBounds: Bool = false
 var fallDirection: FallDirection = .downwards

 */

///     - emitterPosition: Describes the position of the root of the effect. Implemented as an enum with the following options: `.top`, `.center`, and `.bottom`. Default value is `.top`.
///     - clipsToBounds: specifies whether the effect is constrained to the `ConfettiView` itself or can leak around. Default is `false` (effect leaks outside).
///     - fallDirection: an enum value of type `FallDirection`. There are two options for now, being `.upwards` (particles are moving up the screen from the source they are emitted) and `.downwards` (particles are falling downwards from the origin of the source). Default is `.downwards`.
/*
 // default values for base configs view values
 var birthRateValue: Float { get }
 var lifetimeValue: Float { get }
 var velocityValue: CGFloat { get }
 var alphaSpeedValue: Float { get }
 var spreadRadiusValue: CGFloat { get }
 
 
*/


extension Array {
    mutating func filtered(isIncluded: (inout Element) -> Bool) {
        var writeIndex = self.startIndex
        for readIndex in self.indices {
            var element = self[readIndex]
            if isIncluded(&element) {
                // copy over using existing array to prevent having to copy entire array (basically doing the same but this also allows for mutating functions.
                self[writeIndex] = element
                writeIndex = self.index(after: writeIndex)
            }
        }
        self.removeLast(self.distance(from: writeIndex, to: self.endIndex))
    }
}
#endif
