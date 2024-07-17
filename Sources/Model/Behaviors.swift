//
//  Behaviors.swift
//
//
//  Created by Ben Ku on 6/21/24.
//

import Compatibility
//import CustomType

/// The rate at which new particles are generated (may be slower than specified if the frame rate/animation loop is slow)
//@CreateCustomType
//private enum BirthRateEnum: TimeInterval {
//    case periodic = 1
//#warning("Try 0.3")
//    case slow = 0.1
//#warning("Try 0.1")
//    case medium = 0.01
//#warning("Try 0.01")
//    case frequent = 0.001
//}
/// The rate at which new particles are generated (may be slower than specified if the frame rate/animation loop is slow)
public struct BirthRate: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: TimeInterval

    public static let periodic: Self = 0.6
    public static let slow: Self = 0.3
    public static let medium: Self = 0.1
    public static let frequent: Self = 0.01

    public static let named: OrderedDictionary<Self, String> = [
        .periodic: "periodic",
        .slow: "slow",
        .medium: "medium",
        .frequent: "frequent",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = TimeInterval(value)
    }
    public init(floatLiteral value: TimeInterval) {
        self.rawValue = TimeInterval(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
}

/// The Lifetime is controlling the longevity of elements on the screen. That means if the lifetime is shorter, the elements will disappear earlier, while for longer lifetimes they will stay on the screen for longer time.
//@CreateCustomType
//private enum LifetimeEnum: TimeInterval {
//    /// the shortest lifetime (very brief)
//    case brief = 0.2
//    /// Elements only stay for the screen for a short amount of time
//    case short = 1
//    /// Elements will stay on the screen for a longer time and will then disappear.
//    case medium = 2
//    /// Elements will stay on the screen for a long time and only then disappear.
//    case long = 4
//}
/// The Lifetime is controlling the longevity of elements on the screen. That means if the lifetime is shorter, the elements will disappear earlier, while for longer lifetimes they will stay on the screen for longer time.
public struct Lifetime: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: TimeInterval

    /// the shortest lifetime (very brief)
    public static let brief: Self = 0.2
    /// Elements only stay for the screen for a short amount of time
    public static let short: Self = 1
    /// Elements will stay on the screen for a longer time and will then disappear.
    public static let medium: Self = 2
    /// Elements will stay on the screen for a long time and only then disappear.
    public static let long: Self = 4

    public static let named: OrderedDictionary<Self, String> = [
        .brief: "brief",
        .short: "short",
        .medium: "medium",
        .long: "long",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = TimeInterval(value)
    }
    public init(floatLiteral value: TimeInterval) {
        self.rawValue = TimeInterval(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
}

/// The FadeOut describes how fast elements will fade into translucency.
///
/// This control is applied to each particle of the effect and not the effect itself. It is somewhat related to the `lifetime` (see ``Lifetime``) but wheres the `lifetime` will apruptly remove the particle entirely from the screen the fadeout will slowly reduce the opacity of each particle and has a way more subtle effect.
//@CreateCustomType
//private enum FadeOutEnum: TimeInterval {
//    /// The particles will never fade out. Default
//    case none = 0
//    /// The particles will fade out and disappear quickly.
//    case quick = 0.1
//    /// The particles will face out over a medium time period.
//    case moderate = 0.5
//    /// The particles will only slowly fade out.
//    case lengthy = 1
//}

/// The FadeOut describes how fast elements will fade into translucency.
///
/// This control is applied to each particle of the effect and not the effect itself. It is somewhat related to the `lifetime` (see ``Lifetime``) but wheres the `lifetime` will apruptly remove the particle entirely from the screen the fadeout will slowly reduce the opacity of each particle and has a way more subtle effect.
public struct FadeOut: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: TimeInterval

    /// The particles will not fade out. Default
    public static let none: Self = 0
    /// The particles will fade out and disappear quickly.
    public static let quick: Self = 0.1
    /// The particles will face out over a medium time period.
    public static let moderate: Self = 0.5
    /// The particles will only slowly fade out as soon as it's born.
    public static let lengthy: Self = 1

    public static let named: OrderedDictionary<Self, String> = [
        .none: "none",
        .quick: "quick",
        .moderate: "moderate",
        .lengthy: "lengthy",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = TimeInterval(value)
    }
    public init(floatLiteral value: TimeInterval) {
        self.rawValue = TimeInterval(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
}


/// Used to describe an emissionAngle in degrees with some convenience constants.
/// Degrees position referenced from right and positive moves down
//@CreateCustomType
//private enum DegreesEnum: Double {
//    case top = 270.0
//    case right = 0.0
//    case bottom = 90.0
//    case left = 180.0
//
//    // TODO: Figure out how to include these method bodys into the generated struct?  Or just create an extension
//    @available(*, deprecated, message: "See if we can delete this?")
//    var vector: Vector {
//        let x = cos(self.rawValue * .pi / 180)
//        let y = sin(self.rawValue * .pi / 180)
//        return Vector(x: x, y: y)
//    }
//}
/// Used to describe an emissionAngle in degrees with some convenience constants.
/// Degrees position referenced from right and positive moves down
public struct Degrees: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: Double
    
    public static let top: Self = 270.0
    public static let right: Self = 0.0
    public static let bottom: Self = 90.0
    public static let left: Self = 180.0
    
    public static let named: OrderedDictionary<Self, String> = [
        .top: "top",
        .right: "right",
        .bottom: "bottom",
        .left: "left",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = Double(value)
    }
    public init(floatLiteral value: Double) {
        self.rawValue = Double(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
    
    var vector: Vector {
        let x = cos(self.rawValue * .pi / 180)
        let y = sin(self.rawValue * .pi / 180)
        return Vector(x: x, y: y)
    }
}

//@CreateCustomType
//private enum SpreadArcEnum: Degrees {
//    case none = 0
//    case tight = 15
//    case medium = 45
//    case wide = 90
//    case flat = 180
//    case full = 270
//    case complete = 360
//}
public struct SpreadArc: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: Double

    public static let none: Self = 0
    public static let tight: Self = 15
    public static let medium: Self = 45
    public static let wide: Self = 90
    public static let flat: Self = 180
    public static let full: Self = 270
    public static let complete: Self = 360

    public static let named: OrderedDictionary<Self, String> = [
        .none: "none",
        .tight: "tight",
        .medium: "medium",
        .wide: "wide",
        .flat: "flat",
        .full: "full",
        .complete: "complete",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = Double(value)
    }
    public init(floatLiteral value: Double) {
        self.rawValue = value
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
}

//@CreateCustomType
//private enum InitialVelocityEnum: Double {
//    case none = 0
//    case slow = 0.5
//    case medium = 1
//    case fast = 2
//}
public struct InitialVelocity: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: Double

    public static let none: Self = 0
    public static let slow: Self = 0.5
    public static let medium: Self = 1
    public static let fast: Self = 2

    public static let named: OrderedDictionary<Self, String> = [
        .none: "none",
        .slow: "slow",
        .medium: "medium",
        .fast: "fast",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = Double(value)
    }
    public init(floatLiteral value: Double) {
        self.rawValue = Double(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
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

//@CreateCustomType
//private enum BlurEnum: Double {
//    case none = 0, light = 3, heavy = 10 // blur in, blur out, blur inout - TODO: Have curve function?
//}
public struct Blur: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: Double

    public static let none: Self = 0
    public static let light: Self = 3
    public static let heavy: Self = 10 // blur in, blur out, blur inout - TODO: Have curve function?

    public static let named: OrderedDictionary<Self, String> = [
        .none: "none",
        .light: "light",
        .heavy: "heavy",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = Double(value)
    }
    public init(floatLiteral value: Double) {
        self.rawValue = Double(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\(name)"
        }
        return String(describing: rawValue)
    }
}

public enum Coloring: Hashable, CaseIterable, Sendable {
    case none, rainbow, fire
    public var description: String {
        switch self {
        case .none:
            return "⚪️"
        case .rainbow:
            return "🌈"
        case .fire:
            return "🔥"
        }
    }
}
