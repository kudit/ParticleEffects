import Foundation

public struct Particle: Hashable, Sendable {
    public let creationDate = Date.now.timeIntervalSinceReferenceDate
    /// Stable creation index used by renderers to choose deterministic content or styling.
    ///
    /// The particle model intentionally does not store text, symbols, emoji, images, or colors.  Those are
    /// renderer concerns in the v2 API, and the index gives renderers a stable value for cycling through their
    /// own content lists without putting render payload into the behavior system.
    public let index: Int
    
    public let initialPosition: Vector
    public let initialVelocity: Vector

    public init(index: Int, initialPosition: Vector, initialVelocity: Vector) {
        self.index = index
        self.initialPosition = initialPosition
        self.initialVelocity = initialVelocity
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

/// Shared names for extra numeric values that a behavior can attach to a rendered particle state.
///
/// Keeping these names centralized makes the dictionary in ``ParticleState`` useful without forcing every
/// behavior or renderer to define a full custom state type.  Renderers can use these constants directly, or
/// they can define their own names for custom behavior-specific values.
public enum ParticleStateValueKey {
    /// Generic hue value that custom behavior or coloring systems may publish.
    public static let hue = "hue"
    
    /// Hue value calculated for the built-in fire coloring helper.
    public static let fireHue = "fireHue"
    
    /// Saturation value calculated for the built-in fire coloring helper.
    public static let fireSaturation = "fireSaturation"
}

/// for packaging and storing calculated particle information in a simple struct that can be passed around for view rendering without modifying particle array.
public struct ParticleState: Hashable, Sendable {
    public let particle: Particle
    
    /// Value from 0 (birth) to 1 (death) - cached after doing calculations from behavior since based on creation date and current time and various rates.  Available here so that if we want to do custom calculations or tweaking of values, we can easily do so without re-calculating.
    public var lifetimeAge: Double

    // store calculated values for quick display updates
    public let position: Vector
    public let opacity: Double
    public let blur: Blur
    
    /// Current particle rotation expressed in the same screen-coordinate degrees used by ``Degrees``.
    ///
    /// This is calculated by the behavior so renderers do not have to duplicate lifetime math just to rotate a
    /// custom SwiftUI view.  Built-in renderers apply it automatically through `particleAppearance`.
    public let rotation: Degrees
    
    /// Extra numeric values calculated by the behavior and made available to renderers.
    ///
    /// This is intentionally small and value-based so it stays cheap to copy with ``ParticleState``.  It gives
    /// custom behaviors and coloring systems a place to publish values such as hue, saturation, or any other
    /// renderer-specific scalar without baking every possible property into the core state type.
    public let values: [String: Double]
    
    /// Creates a complete particle state snapshot for rendering.
    ///
    /// The defaults preserve the previous construction pattern used by the built-in previews while allowing
    /// newer behavior code to supply rotation and named values when available.
    public init(
        particle: Particle,
        lifetimeAge: Double = 0,
        position: Vector,
        opacity: Double,
        blur: Blur,
        rotation: Degrees = .zero,
        values: [String: Double] = [:]
    ) {
        self.particle = particle
        self.lifetimeAge = lifetimeAge
        self.position = position
        self.opacity = opacity
        self.blur = blur
        self.rotation = rotation
        self.values = values
    }
    
    /// Returns a named value published by the behavior.
    ///
    /// This helper keeps custom renderer code readable and avoids exposing dictionary syntax everywhere
    /// builder-style renderers need to consume behavior-specific data.
    public func value(named name: String) -> Double? {
        return values[name]
    }
}

public extension ParticleState {
    /// Calculates the saturation used for the built-in fire coloring curve.
    ///
    /// The formula lives in an extension rather than the main stored state so other coloring systems can be
    /// added beside it without making the core ``ParticleState`` definition a catalog of every renderer's math.
    static func fireSaturation(for lifetimeAge: Double) -> Double {
        if lifetimeAge > 0.15 {
            return 1
        } else {
            return 0.1 + 0.9 * lifetimeAge / 0.15
        }
    }
    
    /// Calculates the hue used for the built-in fire coloring curve.
    ///
    /// This remains public so existing callers can continue to use ``fireHue`` while newer renderers can read
    /// the same value from ``values`` when it has already been calculated by the behavior.
    static func fireHue(for lifetimeAge: Double) -> Double {
        if lifetimeAge < 0.5 {
            return 0.16
        } else {
            return 0.16 * (1 - (lifetimeAge - 0.5) / 0.5)
        }
    }
    
    /// Saturation used by the built-in fire coloring helper.
    ///
    /// Prefer the named value when a behavior already calculated it, then fall back to the legacy formula so
    /// manually-created states and older code keep working.
    var fireSaturation: Double {
        return values[ParticleStateValueKey.fireSaturation] ?? Self.fireSaturation(for: lifetimeAge)
    }
    
    /// Hue used by the built-in fire coloring helper.
    ///
    /// Prefer the named value when a behavior already calculated it, then fall back to the legacy formula so
    /// manually-created states and older code keep working.
    var fireHue: Double {
        return values[ParticleStateValueKey.fireHue] ?? Self.fireHue(for: lifetimeAge)
    }
}
