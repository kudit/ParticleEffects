import Foundation

public struct Particle: Hashable, Sendable {
    public let creationDate = Date.now.timeIntervalSinceReferenceDate
    
    public var initialPosition: Vector
    public var initialVelocity: Vector
    // store calculated values for quick display updates
    public var position: Vector
    public var opacity: Double
    public var blur: Blur
    public var string: String
    public var hue: Double?
    /// Value from 0 (birth) to 1 (death) - cached after doing calculations from behavior since based on creation date and current time and various rates.  Available here so that if we want to do custom calculations or tweaking of values, we can easily do so without re-calculating.
    public var age: Double = 0
    
    public init(initialPosition: Vector, initialVelocity: Vector, opacity: Double, blur: Blur, string: String, hue: Double?) {
        self.initialPosition = initialPosition
        self.initialVelocity = initialVelocity
        position = initialPosition
        self.opacity = opacity
        self.blur = blur
        self.string = string
        self.hue = hue
    }
    
    public mutating func updatePosition(at currentTime: TimeInterval, with acceleration: Acceleration) {
        // The equation is: s = ut + (1/2)a t^2
        let time = currentTime - creationDate
        let timedVelocity = initialVelocity * time
        let accelerationComponent = acceleration.vector(for: initialVelocity) * time * time * 0.5
        position = initialPosition + timedVelocity + accelerationComponent
    }
    
    // helper functions for fire coloring
    public var fireSaturation: Double {
        if age > 0.15 {
            return 1
        } else {
            return 0.1 + 0.9 * age / 0.15
        }
    }
    public var fireHue: Double {
        if age < 0.5 {
            return 0.16
        } else {
            return 0.16 * (1 - (age - 0.5) / 0.5)
        }
    }
}
