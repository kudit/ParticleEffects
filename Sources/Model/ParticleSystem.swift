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

    public init(center: UnitPoint = .center, behavior: ParticleBehavior = .default) {
        self.center = center
        self.behavior = behavior
    }
        
    public func particles(for currentTime: TimeInterval) -> [Particle] {
        #warning("This causes runtime warning.  Find way of updating outside of this.  Does a timer actually work?  Do we need to publish updates?  Use Keyframe animations?  Or change to draw with canvas with Timeline View?  Perhaps add each particle and then animate along keypath or final position using withAnimation { } ??  Does that work outside of SwiftUI?   Can I animate using physics?  There has to be physics bodies with animation/SwiftUI.  Watch talks?  Use Canvas.  context.draw(image, at: Point)  Canvas has size so we don't need a geometry reader.  Canvas will prevent drawing outside though??  https://developer.apple.com/wwdc21/10021?time=868 Use context.resolve() to resolve similar images for a string?  Create all the possible images to resolve from behavior and have them in an array for use by the context.  Create inner context for each particle to control color and opacity.")
        update(at: currentTime) // TODO: Figure out where better to put this.
        return particles
    }
    
    // TODO: Move additionalConfiguration to an optional additional function on the particle system.
    /// Generate new particle and update existing particles based on behavior. `additionalConfiguration` will be the closure executed when creating new particles and updating particles in case we need to customize any particle state.  The callback first indicates whether this is a new particle or existing, and passes an inout particle that can be modified, and then it returns whether the particle should be deleted.
    public func update(at currentTime: TimeInterval, additionalConfiguration: (Bool, inout Particle) -> Bool = { _,_ in true }) {
        particles.filtered { particle in
            behavior.update(particle: &particle, currentTime: currentTime) && additionalConfiguration(false, &particle)
        }
        
        // pass in the time so we know how frequent to generate...store last time so that this isn't framerate dependent
        if var newParticle = behavior.newParticle(initialPosition: center.vector, timeSinceLastGeneration: currentTime - lastParticleCreation, particleCount: particleCounter), additionalConfiguration(true, &newParticle) {
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
