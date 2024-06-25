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
    public var particleState: ParticleState
    public var coloring: Coloring = .none
    var particle: Particle {
        particleState.particle
    }
    public var body: some View {
        Group {
            if let image = Image(string: particle.string) {
                image
            } else {
                Text(particle.string).font(.title)
            }
        }
        .apply(coloring: coloring, for: particleState)
        .opacity(particleState.opacity)
        .blur(radius: particleState.blur.rawValue)
    }
}

public extension View {
    func apply(coloring: Coloring, for particleState: ParticleState) -> some View {
        Group {
            if let hue = particleState.particle.hue {
                self.foregroundStyle(Color(hue: hue, saturation: 1, brightness: 1))
            } else if coloring == .fire {
                self.foregroundStyle(Color(hue: particleState.fireHue, saturation: particleState.fireSaturation, brightness: 1))
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
        ParticleView(particleState: .init(particle: .init(index: 0, initialPosition: .zero, initialVelocity: .zero, hue: nil, string: "Hi"), position: .zero, opacity: 1, blur: .none), coloring: .none)
        Divider()
        ParticleView(particleState: .init(particle: .init(index: 1, initialPosition: .zero, initialVelocity: .zero, hue: nil, string: "star.fill"), position: .zero, opacity: 1, blur: .light), coloring: .none)
            .foregroundStyle(.yellow)
        Divider()
        ParticleView(particleState: .init(particle: .init(index: 2, initialPosition: .zero, initialVelocity: .zero, hue: nil, string: "triangle.fill"), position: .zero, opacity: 1, blur: .heavy), coloring: .rainbow)
        Divider()
        ParticleView(particleState: .init(particle: .init(index: 3, initialPosition: .zero, initialVelocity: .zero, hue: nil, string: "circle.fill"), position: .zero, opacity: 1, blur: .light), coloring: .fire)
        Divider()
        ParticleView(particleState: .init(particle: .init(index: 4, initialPosition: .zero, initialVelocity: .zero, hue: nil, string: "😆"), position: .zero, opacity: 1, blur: .none), coloring: .none)
        Divider()
    }
}
#endif
