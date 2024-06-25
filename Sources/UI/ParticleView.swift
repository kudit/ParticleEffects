//
//  SwiftUIView.swift
//  
//
//  Created by Ben Ku on 6/21/24.
//

#if canImport(SwiftUI)
import SwiftUI

/// Create a String representation which will first try to find an image resource with the name, next it will try to create a symbol from the string, next it will check to see if it's an emoji or a character or it will just render the text as an image.
public struct ParticleView: View {
    public var particle: Particle
    public var coloring: Coloring = .none
    public var body: some View {
        Group {
            if let image = Image(string: particle.string) {
                image
            } else {
                Text(particle.string).font(.title)
            }
        }
        .apply(coloring: coloring, for: particle)
        .opacity(particle.opacity)
        .blur(radius: particle.blur.rawValue)
    }
}

public extension View {
    func apply(coloring: Coloring, for particle: Particle) -> some View {
        Group {
            if let hue = particle.hue {
                self.foregroundStyle(Color(hue: hue, saturation: 1, brightness: 1))
            } else if coloring == .fire {
                self.foregroundStyle(Color(hue: particle.fireHue, saturation: particle.fireSaturation, brightness: 1))
            } else {
                self
            }
        }
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

#Preview {
    VStack {
        Divider()
        ParticleView(particle: .init(initialPosition: .zero, initialVelocity: .zero, opacity: 1, blur: .none, string: "Hi", hue: nil), coloring: .none)
        Divider()
        ParticleView(particle: .init(initialPosition: .zero, initialVelocity: .zero, opacity: 1, blur: .light, string: "star.fill", hue: nil), coloring: .none)
            .foregroundStyle(.yellow)
        Divider()
        ParticleView(particle: .init(initialPosition: .zero, initialVelocity: .zero, opacity: 1, blur: .heavy, string: "triangle.fill", hue: nil), coloring: .rainbow)
        Divider()
        ParticleView(particle: .init(initialPosition: .zero, initialVelocity: .zero, opacity: 1, blur: .light, string: "circle.fill", hue: nil), coloring: .fire)
        Divider()
        ParticleView(particle: .init(initialPosition: .zero, initialVelocity: .zero, opacity: 1, blur: .none, string: "😆", hue: nil), coloring: .none)
        Divider()
    }
}
#endif
