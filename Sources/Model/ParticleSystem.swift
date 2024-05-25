#if canImport(SwiftUI)
import SwiftUI

public extension UnitPoint {
    var vector: Vector {
        return Vector(x: self.x, y: self.y)
    }
}

/// For Type Erasure
public class ParticleSystem<Configuration: ParticleConfiguration> {    
    public typealias TypedParticle = Particle<Configuration>
    public var particles = [TypedParticle]()
    /// Where emissions happen from
    public var center = UnitPoint.center
    public var behavior: ParticleBehavior
    
    private var frame = 0
    
    public init(center: UnitPoint = .center, behavior: ParticleBehavior = .default) {
        self.center = center
        self.behavior = behavior
    }
    
    /// Generate new particle and update existing particles based on behavior. `configuration` will be the closure executed when creating new particles to get the next configuration.
    public func update(at currentTime: TimeInterval, configuration: () -> Configuration) {
        particles.filtered { particle in
            behavior.update(particle: &particle, at: currentTime)
        }
        
        if let newParticle = behavior.generationTick(origin: center.vector, configuration: configuration) {
            particles.append(newParticle)
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
            let include = isIncluded(&element)
            if include {
                // copy over using existing array to prevent having to copy entire array (basically doing the same but this also allows for mutating functions.
                self[writeIndex] = element
                writeIndex = self.index(after: writeIndex)
            }
        }
        self.removeLast(self.distance(from: writeIndex, to: self.endIndex))
    }
}
#endif
