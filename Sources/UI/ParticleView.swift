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
    public var content: String
    public var particleState: ParticleState
    public var coloringStyle: ParticleColoringStyle

    /// Creates the default automatic particle view with renderer-provided content and the simple coloring enum.
    ///
    /// The content belongs to the renderer in the v2 API; this view only decides whether that content should
    /// resolve as an image asset, SF Symbol, or text for the current particle.
    public init(content: String, particleState: ParticleState, coloring: Coloring = .none) {
        self.content = content
        self.particleState = particleState
        self.coloringStyle = ParticleColoringStyle(coloring)
    }
    
    /// Creates the default automatic particle view with renderer-provided content and a custom coloring style.
    ///
    /// Use this when a renderer wants to supply color calculation as a closure instead of one of the built-in
    /// ``Coloring`` enum cases.
    public init(content: String, particleState: ParticleState, coloringStyle: ParticleColoringStyle) {
        self.content = content
        self.particleState = particleState
        self.coloringStyle = coloringStyle
    }
    
    public var body: some View {
        Group {
            if let image = Image(string: content) {
                image
            } else {
                Text(content).font(.title)
            }
        }
        .particleAppearance(for: particleState, coloringStyle: coloringStyle)
    }
}

public extension View {
    /// Applies the standard particle visual modifiers to a custom SwiftUI view.
    ///
    /// Custom renderers can call this modifier to get the same coloring, opacity, blur, and rotation behavior
    /// used by the built-in renderers while still fully controlling the particle's SwiftUI content.
    func particleAppearance(for particleState: ParticleState, coloring: Coloring = .none) -> some View {
        return particleAppearance(for: particleState, coloringStyle: ParticleColoringStyle(coloring))
    }
    
    /// Applies the standard particle visual modifiers to a custom SwiftUI view with an injectable coloring style.
    ///
    /// Position is intentionally not applied here because ``ParticleSystemView`` owns layout and places each
    /// renderer output at ``ParticleState/position`` inside the current geometry.
    func particleAppearance(for particleState: ParticleState, coloringStyle: ParticleColoringStyle) -> some View {
        self
            .apply(coloringStyle: coloringStyle, for: particleState)
            .opacity(particleState.opacity)
            .blur(radius: particleState.blur.rawValue)
            .rotationEffect(.degrees(particleState.rotation.rawValue))
    }
    
    /// Applies a built-in coloring enum to the view while preserving the legacy helper name.
    func apply(coloring: Coloring, for particleState: ParticleState) -> some View {
        return apply(coloringStyle: ParticleColoringStyle(coloring), for: particleState)
    }
    
    /// Applies a resolved coloring style to the view if the style supplies a color.
    ///
    /// If the style returns `nil`, the view is left unmodified so it can inherit foreground styling from its
    /// surrounding SwiftUI hierarchy.
    func apply(coloringStyle: ParticleColoringStyle, for particleState: ParticleState) -> some View {
        Group {
            if let color = coloringStyle.color(for: particleState) {
                self.foregroundStyle(color)
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
    
    static let `default` = Image(systemName: "star")
#if canImport(UIKit)
    static let defaultColor = UIColor.white
#else //if canImport(AppKit)
    static let defaultColor = NSColor.white
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
        ParticleView(content: "Hi", particleState: .init(particle: .init(index: 0, initialPosition: .zero, initialVelocity: .zero), position: .zero, opacity: 1, blur: .none), coloring: .none)
        Divider()
        ParticleView(content: "star.fill", particleState: .init(particle: .init(index: 1, initialPosition: .zero, initialVelocity: .zero), position: .zero, opacity: 1, blur: .light), coloring: .none)
            .foregroundStyle(.yellow)
        Divider()
        ParticleView(content: "triangle.fill", particleState: .init(particle: .init(index: 2, initialPosition: .zero, initialVelocity: .zero), position: .zero, opacity: 1, blur: .light), coloring: .rainbow)
        Divider()
        ParticleView(content: "circle.fill", particleState: .init(particle: .init(index: 3, initialPosition: .zero, initialVelocity: .zero), position: .zero, opacity: 1, blur: .heavy), coloring: .fire)
        Divider()
        ParticleView(content: "😆", particleState: .init(particle: .init(index: 4, initialPosition: .zero, initialVelocity: .zero), position: .zero, opacity: 1, blur: .none), coloring: .none)
        Divider()
    }
}
#endif
