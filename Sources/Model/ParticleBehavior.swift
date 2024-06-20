import Foundation

public typealias Degrees = Double
/// Degrees position referenced from right and positive moves down
public extension Degrees {
    static let top = 270.0
    static let right = 0.0
    static let bottom = 90.0
    static let left = 180.0
    
    var vector: Vector {
        let x = cos(self * .pi / 180)        
        let y = sin(self * .pi / 180)
        return Vector(x: x, y: y)
    }
    
    var description: String {
        if self == .top {
            return ".top"
        } else if self == .right {
            return ".right"
        } else if self == .bottom {
            return ".bottom"
        } else if self == .left {
            return ".left"
        } else {
            return "\(Double(self))"
        }
    }
}

public enum InitialVelocity: Hashable, CaseIterable, Sendable {
    case none, slow, medium, fast
    
    public var multiplier: Double {
        switch self {
        case .none:
            return 0
        case .slow:
            return 0.5
        case .medium:
            return 1
        case .fast:
            return 2
        }
    }
}

// frames per second is typically 60 or 120
public enum BirthRate: Hashable, CaseIterable, Sendable {
    case periodic, slow, medium, frequent
    
    public var value: Int {
        switch self {
        case .periodic:
            return 60 // every second
        case .slow:
            return 20
        case .medium:
            return 5
        case .frequent:
            return 1
        }
    }
}

public enum SpreadArc: Degrees, Hashable, CaseIterable, Sendable {
    case none = 0, tight = 15, medium = 45, wide = 90, flat = 180, full = 270, complete = 360
}

/// various modes (none, gravity, anti-gravity (for floating/smoke/fire/bubbles), sun (towards center - opposite vector?)
public enum Acceleration: Hashable, CaseIterable, Sendable {
    case none, gravity, antiGravity, moonGravity, antiMoonGravity, sun
    public func vector(for initialVelocity: Vector) -> Vector {
        switch self {
        case .none:
            return .zero
        case .gravity:
            // sign is flipped for screen
            return Vector(x: 0, y: 9.8)
        case .antiGravity:
            // sign is flipped for screen
            return Vector(x: 0, y: -9.8)
        case .moonGravity:
            // sign is flipped for screen
            return Vector(x: 0, y: 1)
        case .antiMoonGravity:
            // sign is flipped for screen
            return Vector(x: 0, y: -1)
        case .sun:
            return -initialVelocity
        }
    }
}

public enum Blur: Hashable, CaseIterable, Sendable {
    case none, light, heavy // blur in, blur out, blur inout - TODO: Have curve function?
    public var value: Double {
        switch self {
        case .none:
            return 0
        case .light:
            return 3
        case .heavy:
            return 10
        }
    }
}

public struct ParticleBehavior: Hashable, Sendable {
    public static let rain = ParticleBehavior(
        label: "Rain",
        birthRate: .frequent,
        lifetime: .medium,
        fadeOut: .none,
        emissionAngle: .bottom,
        spread: .flat,
        initialVelocity: .slow,
        acceleration: .gravity
    )
    public static let fountain = ParticleBehavior(
        label: "Fountain",
        birthRate: .frequent,
        lifetime: .long,
        fadeOut: .quick,
        emissionAngle: .top,
        spread: .tight,
        initialVelocity: .medium,
        acceleration: .moonGravity
    )
    public static let smoke = ParticleBehavior(
        label: "Smoke",
        birthRate: .medium,
        lifetime: .medium,
        fadeOut: .lengthy,
        emissionAngle: .top,
        spread: .flat,
        initialVelocity: .slow,
        acceleration: .antiMoonGravity,
        blur: .heavy
    )
    public static let bubbles = ParticleBehavior(
        label: "Bubbles",
        birthRate: .slow,
        lifetime: .medium,
        fadeOut: .none,
        emissionAngle: .top,
        spread: .wide,
        initialVelocity: .slow,
        acceleration: .none
    )
    public static let fire = ParticleBehavior(
        label: "Fire",
        birthRate: .frequent,
        lifetime: .brief,
        fadeOut: .moderate,
        emissionAngle: .top,
        spread: .medium,
        initialVelocity: .slow,
        acceleration: .antiGravity,
        blur: .heavy
    )
    public static let sparkle = ParticleBehavior(
        label: "Sparkle",
        birthRate: .medium,
        lifetime: .brief,
        fadeOut: .none,
        emissionAngle: .top,
        spread: .full,
        initialVelocity: .fast,
        acceleration: .none
    )
    public static let sun = ParticleBehavior(
        label: "Sun",
        birthRate: .frequent,
        lifetime: .medium,
        fadeOut: .moderate,
        emissionAngle: .top,
        spread: .complete,
        initialVelocity: .medium,
        acceleration: .sun,
        blur: .light
    )
    
    public static let presets = [Self.rain, .fountain, .bubbles, .smoke, .fire, .sparkle, .sun]
    
    private var frame = 0
    public private(set) var label: String 
    
    ///.    - `birthRate`: Defines how frequently new particles are spawned.
    public var birthRate: BirthRate
    
    ///     - `lifetime`: Defines how long the single elements of the effect will stay alive. The type is ``Lifetime`` (click to see more details) and it has the values `.short`, `.medium` and `.long`. Default is `.medium`.
    public var lifetime: Lifetime
    
    ///     - `fadeOut`: Specifies how fast elements of the effect will fade out (meaning: become transparent). Difference to `lifetime` is that there elements will be removed instantly whereas here there is a fading effect that is more subtle over time. The type is ``FadeOut`` (click to see more details) with the values `.none`, `.quick`, `.moderate`, `.lengthy`. Default is `.moderate`.
    public var fadeOut: FadeOut
    
    // Where the center of the emission should start.  0 represents right, 90 represents down.
    public var emissionAngle: Degrees

    ///     - `spread`: Defines the angle in which the single elements of the effect are emitted. The type ``SpreadArc`` (click to see more details) defines 7 values: `.none`, `.tight`, `.medium`, `.wide`, `.flat`, `.full`, and `.complete`.
    public var spread: SpreadArc

    ///     - `initialVelocity`: Specifies the initial speed with which confetti particles will be emitted from the source. The higher the value the larger the radius of the effects as elements will spread in a larger radius around the source. The type is ``InitialVelocity`` and possible values are `.slow`, `.medium`, and `.fast`. Default value is `.medium`.
    public var initialVelocity: InitialVelocity
    
    /// various modes (none, gravity, anti-gravity (for floating/smoke/fire/bubbles), sun (towards center - opposite vector?)
    public var acceleration: Acceleration

    public var blur: Blur = .none
    
    public var scale: Double = 1 // scale behavior of the particle.  Up and down, down and up, down, up.  Will go from 0 to 1 for up, 2 to 1 for down, change to min/max?  Have a timing curve?
    ///     - `accelleration`: Defines the accelleration parameter for the particle physics.  For earth gravity, use 9.8 in the y direction.  TODO: allow setting a value at an angle (store as angle and magnitude and expose x and y that are calculated?  Or since we're using x and y more, have init that takes an angle and magnitude and calculates once and sets the x and y values√)
    
    public static var `default` = ParticleBehavior()
    
    public init(
        label: String = "Custom",
        birthRate: BirthRate = .medium,
        lifetime: Lifetime = .medium,
        fadeOut: FadeOut = .moderate,
        emissionAngle: Degrees = 0,
        spread: SpreadArc = .medium,
        initialVelocity: InitialVelocity = .medium,
        acceleration: Acceleration = .gravity,
        blur: Blur = .none,
        scale: Double = 1)
    {
        self.label = label
        self.birthRate = birthRate
        self.lifetime = lifetime
        self.fadeOut = fadeOut
        self.emissionAngle = emissionAngle
        self.spread = spread
        self.initialVelocity = initialVelocity
        self.acceleration = acceleration
        self.blur = blur
        self.scale = scale
    }
        
    /// Determine whether to create a new particle and if so, return a new particle with an initial position and configuration.
    public mutating func generationTick<Configuration: ParticleConfiguration>(origin: Vector, configuration: () -> Configuration) -> Particle<Configuration>? {
        defer {
            frame += 1
        }
        // spawn one new particle each tick (or less frequent if birth rate is higher)
        guard frame % birthRate.value == 0 else {
            return nil
        }
        
        // initialize with behavior from the ranges set up

        // determine initial direction within spread range
        let halfSpread = spread.rawValue / 2.0
        let lower = emissionAngle - halfSpread
        let upper = emissionAngle + halfSpread
        let angle = Degrees.random(in: lower...upper)
        let vector = angle.vector * initialVelocity.multiplier
        
        // particles should start opaque
        let particle = Particle(initialPosition: origin, initialVelocity: vector, opacity: 1, blur: blur.value, configuration: configuration())

        return particle
    }
    
    /// Update the particle position and configuration using the behavior.  Return `false` if the particle should be removed and no longer updated.
    public func update<Configuration: ParticleConfiguration>(particle: inout Particle<Configuration>, at currentTime: TimeInterval) -> Bool {
        // update age
        particle.age = (currentTime - particle.creationDate) / lifetime.duration
        
        // update the velocity due to acceleration
        particle.updatePosition(at: currentTime, with: acceleration)
        
        // allow configuration to update itself
        particle.configuration.update(particle: particle, behavior: self, at: currentTime)
        
        // update fade and opacity
        let fadeOutDuration = lifetime.duration * fadeOut.multiplier
        let fadeStartTime = particle.creationDate + lifetime.duration - fadeOutDuration
        if currentTime < fadeStartTime {
            // don't touch opacity and don't remove from view 
        } else {
            particle.opacity = 1 - ((currentTime - fadeStartTime) / fadeOutDuration)
            if particle.opacity < 0 {
                // we should be dead.  Remove from view
                return false
            }
        }
        return true
    }
    
    public var code: String {
        return """
ParticleBehavior(
    birthRate: .\(String(describing: birthRate)),
    lifetime: .\(String(describing: lifetime)),
    fadeOut: .\(String(describing: fadeOut)),
    emissionAngle: \(emissionAngle.description),
    spread: .\(String(describing: spread)),
    initialVelocity: .\(String(describing: initialVelocity)),
    acceleration: .\(String(describing: acceleration)),
    blur: .\(String(describing: blur))
)
"""
    } 
}
