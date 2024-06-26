import Foundation

/// A specific combination of properties that effects the position, opacity, creation, and death of particles.
public struct ParticleBehavior: Hashable, Sendable {
    public static let rain = ParticleBehavior(
        label: "Rain",
        string: "drop.fill",
        birthRate: .frequent,
        lifetime: .medium,
        fadeOut: .none,
        emissionAngle: .bottom,
        spread: .flat,
        initialVelocity: .slow,
        acceleration: .gravity,
        blur: .none
    )
    public static let fountain = ParticleBehavior(
        label: "Fountain",
        string: "😊,👍,☺️,👏,🙌",
        birthRate: .frequent,
        lifetime: .long,
        fadeOut: .quick,
        emissionAngle: .top,
        spread: .tight,
        initialVelocity: .medium,
        acceleration: .moonGravity,
        blur: .none
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
        string: "circle",
        birthRate: .slow,
        lifetime: .medium,
        fadeOut: .none,
        emissionAngle: .top,
        spread: .wide,
        initialVelocity: .slow,
        acceleration: .none,
        blur: .none,
        coloring: .rainbow
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
        blur: .heavy,
        coloring: .fire
    )
    public static let sparkle = ParticleBehavior(
        label: "Sparkle",
        string: "star",
        birthRate: .frequent,
        lifetime: .brief,
        fadeOut: .none,
        emissionAngle: .top,
        spread: .full,
        initialVelocity: .fast,
        acceleration: .none,
        blur: .none,
        coloring: .rainbow
    )
    public static let sun = ParticleBehavior(
        label: "Sun",
        string: "star.fill",
        birthRate: .frequent,
        lifetime: .medium,
        fadeOut: .moderate,
        emissionAngle: .top,
        spread: .complete,
        initialVelocity: .slow,
        acceleration: .sun,
        blur: .light,
        coloring: .fire
    )
    
    public static let presets = [Self.rain, .fountain, .bubbles, .smoke, .fire, .sparkle, .sun]
    
    public let label: String
    
    /// Defines what should be rendered.  Can be a comma-sparated list to assign each element to a different particle in order of creation.
    public var string: String
    
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
    
    public var coloring: Coloring = .none
    
    public static let `default` = ParticleBehavior()
    
    public init(
        label: String = "Custom",
        string: String = "circle.fill",
        birthRate: BirthRate = .medium,
        lifetime: Lifetime = .medium,
        fadeOut: FadeOut = .moderate,
        emissionAngle: Degrees = 0,
        spread: SpreadArc = .medium,
        initialVelocity: InitialVelocity = .medium,
        acceleration: Acceleration = .gravity,
        blur: Blur = .heavy,
        coloring: Coloring = .none,
        scale: Double = 1)
    {
        self.label = label
        self.string = string
        self.birthRate = birthRate
        self.lifetime = lifetime
        self.fadeOut = fadeOut
        self.emissionAngle = emissionAngle
        self.spread = spread
        self.initialVelocity = initialVelocity
        self.acceleration = acceleration
        self.blur = blur
        self.coloring = coloring
        self.scale = scale
    }

    public func modified(
        string: String? = nil,
        birthRate: BirthRate? = nil,
        lifetime: Lifetime? = nil,
        fadeOut: FadeOut? = nil,
        emissionAngle: Degrees? = nil,
        spread: SpreadArc? = nil,
        initialVelocity: InitialVelocity? = nil,
        acceleration: Acceleration? = nil,
        blur: Blur? = nil,
        coloring: Coloring? = nil,
        scale: Double? = nil) -> Self
    {
        var modified = self
        if let string {
            modified.string = string
        }
        if let birthRate {
            modified.birthRate = birthRate
        }
        if let lifetime {
            modified.lifetime = lifetime
        }
        if let fadeOut {
            modified.fadeOut = fadeOut
        }
        if let emissionAngle {
            modified.emissionAngle = emissionAngle
        }
        if let spread {
            modified.spread = spread
        }
        if let initialVelocity {
            modified.initialVelocity = initialVelocity
        }
        if let acceleration {
            modified.acceleration = acceleration
        }
        if let blur {
            modified.blur = blur
        }
        if let coloring {
            modified.coloring = coloring
        }
        if let scale {
            modified.scale = scale
        }
        return modified
    }
    
    var strings: [String] {
        return string.components(separatedBy: ",")
    }

    func string(for particleCount: Int) -> String {
        // go ahead and try to split since code will work even if comma not present
        let parts = strings
        let index = particleCount % parts.count // make sure we have a valid index
        return parts[index]
    }
        
    /// Determine whether to create a new particle and if so, return a new particle with an initial position and configuration.
    func newParticle(initialPosition: Vector, timeSinceLastGeneration: TimeInterval, particleCount: Int) -> Particle? {
        guard timeSinceLastGeneration > birthRate.rawValue else {
            // too quick since last generation.  No need to generate
            return nil
        }
        // get the string for this actual particle
        let particleString = string(for: particleCount)
        
        // initialize with behavior from the ranges set up

        // determine initial direction within spread range
        let halfSpread = spread.rawValue / 2.0
        let lower = emissionAngle.rawValue - halfSpread
        let upper = emissionAngle.rawValue + halfSpread
        let angle = Degrees(floatLiteral: Double.random(in: lower...upper))
        let initialVelocityVector = angle.vector * initialVelocity.rawValue
        
        // determine hue (if rainbow coloring set - other colorings will use age in renderer and we don't need to calculate here since not using hue value)
        let hue = coloring != .rainbow ? nil : {
            // one hundred hue options
            let index = particleCount % 100
            return Double(index) / 100
        }()
        
        // particles should start opaque
        return Particle(index: particleCount, initialPosition: initialPosition, initialVelocity: initialVelocityVector, hue: hue, string: particleString)
    }

    /// Update the particle position and configuration.  Return `false` if the particle should be removed and no longer updated.
    func currentState(for particle: Particle, at currentTime: TimeInterval) -> ParticleState {
        // update age (for use in fire coloring equations)
        let lifetimeAge = particle.age(at: currentTime) / lifetime.rawValue

        // update the velocity due to acceleration
        let position = particle.position(at: currentTime, with: acceleration)
                
        // update fade and opacity
        let fadeOutDuration = lifetime.rawValue * fadeOut.rawValue
        let fadeStartTime = particle.creationDate + lifetime.rawValue - fadeOutDuration
        let opacity: Double
        if currentTime < fadeStartTime {
            // don't touch opacity and don't remove from view
            opacity = 1
        } else {
            opacity = 1 - ((currentTime - fadeStartTime) / fadeOutDuration)
        }
        
        return ParticleState(particle: particle, lifetimeAge: lifetimeAge, position: position, opacity: opacity, blur: blur)
    }
        
    func shouldRemove(particle: Particle, at currentTime: TimeInterval) -> Bool {
        particle.age(at: currentTime) > lifetime.rawValue
    }
    
    public var code: String {
        for preset in Self.presets {
            if self == preset {
                return ".\(preset.label.lowercased())"
            }
        }
        return """
ParticleBehavior(
    birthRate: \(birthRate),
    lifetime: \(lifetime),
    fadeOut: \(fadeOut),
    emissionAngle: \(emissionAngle),
    spread: \(spread),
    initialVelocity: \(initialVelocity),
    acceleration: \(acceleration),
    blur: \(blur),
    coloring: \(coloring),
    scale: \(scale)
)
"""
    } 
}
