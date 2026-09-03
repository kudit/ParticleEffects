#if canImport(SwiftUI)
import Compatibility
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

    /// Drives model-side particle birth and storage cleanup between SwiftUI render frames.
    ///
    /// The rendered particle positions are calculated from absolute time, but the backing storage still needs
    /// a heartbeat so new particles can be born and old particles can be physically removed from the array.
    /// The timer is installed in common run-loop modes below so mouse/touch tracking does not pause that
    /// heartbeat while the user is dragging or holding a control.
    private var timer: Timer? = nil
    public init(center: UnitPoint = .center, behavior: ParticleBehavior = .default) {
        self.center = center
        self.behavior = behavior
        let updateTimer = Timer(timeInterval: 0.01, repeats: true) { [weak self] _ in
            // Hop explicitly to the model's actor because Timer's callback is not actor-isolated. The weak
            // capture keeps the timer from retaining a view-owned particle system after the view disappears.
            Task { @MainActor [weak self] in
                // Use Foundation's deployment-neutral clock spelling so the SwiftUI-backed system remains
                // buildable on macOS 10.15 and the corresponding first SwiftUI releases on other platforms.
                self?.update(at: Date.nowBackport.timeIntervalSinceReferenceDate)
            }
        }
        // A scheduledTimer is registered in the default run-loop mode only.  Adding the timer to common modes
        // keeps updates flowing during drag/hold interaction tracking, which prevents stale particles from
        // lingering until the user releases the pointer or finger.
        RunLoop.main.add(updateTimer, forMode: .common)
        timer = updateTimer
    }
    deinit {
        timer?.invalidate()
    }
    
    public func particles(for currentTime: TimeInterval) -> [ParticleState] {
        // Render-time filtering is a defensive second gate for expired particles.  If the model cleanup timer
        // is delayed for any reason, SwiftUI should still not draw particles whose lifetime has already ended.
        let activeParticles = particles.filter { particle in
            !behavior.shouldRemove(particle: particle, at: currentTime)
        }
        return activeParticles.map { behavior.currentState(for: $0, at: currentTime) }
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
