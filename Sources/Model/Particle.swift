import Foundation

public extension ParticleBehavior {
    static let version = "1.0.0"
}

public struct Particle<Configuration: ParticleConfiguration>: Hashable {
    public let creationDate = Date.now.timeIntervalSinceReferenceDate

    public var initialPosition: Vector
    public var initialVelocity: Vector
    // store calculated values for quick display updates
    public var position: Vector
    public var opacity: Double
    public var blur: Double
    /// Value from 0 (birth) to 1 (death)
    public var age: Double = 0

    public var configuration: Configuration
    
    public init(initialPosition: Vector, initialVelocity: Vector, opacity: Double, blur: Double, configuration: Configuration) {
        self.initialPosition = initialPosition
        self.initialVelocity = initialVelocity
        position = initialPosition
        self.opacity = opacity
        self.blur = blur
        self.configuration = configuration
    }
    
    public mutating func updatePosition(at currentTime: TimeInterval, with acceleration: Acceleration) {
        // The equation is: s = ut + (1/2)a t^2
        let time = currentTime - creationDate
        let timedVelocity = initialVelocity * time
        let accelerationComponent = acceleration.vector(for: initialVelocity) * time * time * 0.5
        position = initialPosition + timedVelocity + accelerationComponent
    }
}
