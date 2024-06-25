import Foundation

public struct Particle: Hashable, Sendable {
    public let creationDate = Date.now.timeIntervalSinceReferenceDate
    /// Used for determining string so we don't have to store the string we can calculate from behavior if things change
    public let index: Int
    
    public let initialPosition: Vector
    public let initialVelocity: Vector

    public let hue: Double? // since may be created at birth
    
    // could be calculated but store here so we don't need to re-calculate every cycle
    public let string: String

    public init(index: Int, initialPosition: Vector, initialVelocity: Vector, hue: Double?, string: String) {
        self.index = index
        self.initialPosition = initialPosition
        self.initialVelocity = initialVelocity
        self.hue = hue
        self.string = string
    }
    
    public func age(at currentTime: TimeInterval) -> TimeInterval {
        return currentTime - creationDate
    }
    
    public func position(at currentTime: TimeInterval, with acceleration: Acceleration) -> Vector {
        // The equation is: s = ut + (1/2)a t^2
        let time = age(at: currentTime)
        let timedVelocity = initialVelocity * time
        let accelerationComponent = acceleration.vector(for: initialVelocity) * time * time * 0.5
        return initialPosition + timedVelocity + accelerationComponent
    }
}

/// for packaging and storing calculated particle information in a simple struct that can be passed around for view rendering without modifying particle array.
public struct ParticleState: Hashable, Sendable {
    public let particle: Particle
    
    /// Value from 0 (birth) to 1 (death) - cached after doing calculations from behavior since based on creation date and current time and various rates.  Available here so that if we want to do custom calculations or tweaking of values, we can easily do so without re-calculating.
    public var lifetimeAge: Double = 0

    // store calculated values for quick display updates
    public let position: Vector
    public let opacity: Double
    public let blur: Blur
    
    // helper functions for fire coloring
    public var fireSaturation: Double {
        if lifetimeAge > 0.15 {
            return 1
        } else {
            return 0.1 + 0.9 * lifetimeAge / 0.15
        }
    }
    public var fireHue: Double {
        if lifetimeAge < 0.5 {
            return 0.16
        } else {
            return 0.16 * (1 - (lifetimeAge - 0.5) / 0.5)
        }
    }
}
