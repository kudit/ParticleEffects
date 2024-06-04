#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public enum Coloring: Hashable, CaseIterable {
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

public struct StringConfiguration: View, ParticleConfiguration {
    public var string: String

    public var coloring: Coloring
    static var nextHue: Double = 0
    var hue: Double = Self.nextHue
    
    /// Should be a value from 0 to 1 based on age
    var age: Double = 0
    
    static var count = 0

    /// Create a String representation which will first try to find an image resource with the name, next it will try to create a symbol from the string, next it will check to see if it's an emoji or a character or it will just render the text as an image.  Unfortunately requires UIKit meaning this won't work for macOS if not a symbol?    
    public init(string: String, coloring: Coloring = .none) {
        self.string = string
        self.coloring = coloring
        if coloring == .rainbow {
            // increase color
            Self.nextHue += 0.01
            if Self.nextHue > 1 { Self.nextHue -= 1 }
        }
        if string.contains(",") {
            // go through sections and pick the appropriate one
            let parts = string.components(separatedBy: ",")
            let index = Self.count % parts.count
            self.string = parts[index]
            Self.count += 1
        }
    }
    public var view: some View {
        Group {
            if let image = Image(string: string) {
                image
            } else {
                Text(string).font(.title)
            }
        }
    }
    var saturation: Double {
        if age > 0.15 {
            return 1
        } else {
            return 0.1 + 0.9 * age / 0.15
        }
    }
    var fireHue: Double {
        if age < 0.5 {
            return 0.16
        } else {
            return 0.16 * (1 - (age - 0.5) / 0.5)
        }
    }
    public var body: some View {
        switch coloring {
        case .none:
            view
        case .rainbow:
            view.foregroundStyle(Color(hue: hue, saturation: 1, brightness: 1))
        case .fire:
            view.foregroundStyle(Color(hue: fireHue, saturation: saturation, brightness: 1))
        }
    }
    public mutating func update(particle: Particle<Self>, behavior: ParticleBehavior, at currentTime: TimeInterval) {
        age = particle.age
    }
}

public extension Image {
    static func fileExists(name: String) -> Bool {
#if canImport(UIKit)
        UIImage(named: name) != nil
#else
        NSImage(named: name) != nil
#endif
    }
    static func symbolExists(name: String) -> Bool {
#if canImport(UIKit)
        UIImage(systemName: name) != nil
#else
        NSImage(systemSymbolName: name, accessibilityDescription: name) != nil
#endif
    }
    
    static var `default` = Image(systemName: "star")
#if canImport(UIKit)
    static var defaultColor = UIColor.white
#else //if canImport(AppKit)
    static var defaultColor = NSColor.white
#endif

    init?(string: String) {
        if string == "" {
            self = .default
            return
        }
        if Self.fileExists(name: string) {
            self.init(string)
            return
        }
        if Self.symbolExists(name: string) {
            self.init(systemName: string)
            return
        }
        return nil
    }
}

#if swift(>=5.9)
#Preview("Confetti Demo") {
    let behavior = ParticleBehavior(
        birthRate: .frequent,
        lifetime: .long,
        fadeOut: .none,
        emissionAngle: .top,
        spread: .medium,
        initialVelocity: .medium,
        acceleration: .moonGravity,
        blur: .none
    )
    return VStack {
        ParticleSystemView(behavior: behavior, string: "😊,👍,☺️,👏,🙌")
        Color.clear
    }
}

#Preview("Fire Example") {
    ParticleSystemView(behavior: .fire, string: "drop.fill", coloring: .fire)
}
#endif
#endif
