#if canImport(SwiftUI)
import Foundation
import SwiftUI

/// Context passed to custom SwiftUI particle renderers.
///
/// The context groups the information a renderer is most likely to need: the calculated particle state, the
/// owning particle system, the current geometry, and the current timeline time.  Passing a single value keeps
/// the custom-renderer API extensible without adding more closure parameters every time the package exposes
/// another useful bit of render-time information.
@MainActor
public struct ParticleRenderingContext {
    /// Calculated state for the particle being rendered.
    public let particleState: ParticleState
    
    /// Owning system, provided so advanced renderers can inspect behavior or system-level configuration.
    public let particleSystem: ParticleSystem
    
    /// Geometry for the current particle system view.
    ///
    /// This lets custom renderers use the container size when they need to adjust their appearance based on
    /// the available drawing area.  Positioning is still handled by ``ParticleSystemView`` for consistency.
    public let geometry: GeometryProxy
    
    /// Current animation time, using the same time base as ``Particle/creationDate``.
    public let currentTime: TimeInterval
    
    /// Short alias for ``particleState`` that reads naturally in builder-style renderer code.
    public var state: ParticleState {
        return particleState
    }
    
    /// Convenience access to the underlying particle identity and birth-time data.
    public var particle: Particle {
        return particleState.particle
    }
    
    /// Convenience access to the current container size.
    public var size: CGSize {
        return geometry.size
    }
    
    /// Creates a render context for a single particle and timeline frame.
    public init(
        particleState: ParticleState,
        particleSystem: ParticleSystem,
        geometry: GeometryProxy,
        currentTime: TimeInterval
    ) {
        self.particleState = particleState
        self.particleSystem = particleSystem
        self.geometry = geometry
        self.currentTime = currentTime
    }
}

/// Builds a SwiftUI view for a particle state.
///
/// Renderers are deliberately value types in the built-in implementations because the particle system already
/// owns the mutable timeline state.  A custom renderer can store configuration such as fonts, colors, or
/// sizing rules, then produce any SwiftUI view from the supplied ``ParticleRenderingContext``.
@MainActor
public protocol ParticleRenderer {
    associatedtype ParticleBody: View
    
    /// Creates the SwiftUI view used to display a single particle for the current frame.
    @ViewBuilder
    func particleView(for context: ParticleRenderingContext) -> ParticleBody
}

/// Renderer protocol used by deprecated 1.x compatibility initializers.
///
/// Built-in content renderers conform to this so old call sites that passed `string:` to
/// ``ParticleSystemView`` can still compile while the deprecation warning points callers toward moving that
/// content into the renderer itself.
@MainActor
public protocol ParticleContentRenderer: ParticleRenderer {
    /// Returns a copy of the renderer using content supplied by a legacy `string:` argument.
    func replacingContent(_ content: ParticleContent, coloring: Coloring?) -> Self
}

/// Type-erased-by-closure renderer for one-off custom SwiftUI particle views.
///
/// Use this when defining a named renderer type would be unnecessary.  Named renderer structs are still useful
/// for reusable effects because they provide a clear place to document and store configuration.
@MainActor
public struct CustomParticleRenderer<ParticleBody: View>: ParticleRenderer {
    private let content: (ParticleRenderingContext) -> ParticleBody
    
    /// Stores a SwiftUI builder closure that will be called for each particle each frame.
    public init(@ViewBuilder _ content: @escaping (ParticleRenderingContext) -> ParticleBody) {
        self.content = content
    }
    
    /// Builds the custom particle view for the supplied render context.
    public func particleView(for context: ParticleRenderingContext) -> ParticleBody {
        return content(context)
    }
}

/// A color resolver that can be injected into renderers without hard-coding every coloring mode into them.
///
/// Built-in renderers can use the simple ``Coloring`` enum, and advanced callers can provide a closure that
/// resolves a SwiftUI ``Color`` from the current ``ParticleState``.  Keeping coloring in the renderer layer
/// prevents the behavior system from knowing how a particle will be drawn.
@MainActor
public struct ParticleColoringStyle {
    public typealias Resolver = (ParticleState) -> Color?
    
    private let resolver: Resolver
    
    /// Creates a coloring style from a resolver closure.
    ///
    /// Returning `nil` means "do not change the foreground style" so the particle can inherit styling from the
    /// surrounding SwiftUI hierarchy.
    public init(_ resolver: @escaping Resolver) {
        self.resolver = resolver
    }
    
    /// Resolves the color to apply for a particle state, if this style wants to override inherited styling.
    public func color(for particleState: ParticleState) -> Color? {
        return resolver(particleState)
    }
}

public extension ParticleColoringStyle {
    /// Leaves the particle's inherited foreground style unchanged.
    static let none = Self { _ in nil }
    
    /// Applies a deterministic hue from the particle's stable index.
    static let rainbow = Self { particleState in
        let hue = Double(particleState.particle.index % 100) / 100
        return Color(hue: hue, saturation: 1, brightness: 1)
    }
    
    /// Applies the built-in fire hue and saturation curves.
    static let fire = Self { particleState in
        return Color(hue: particleState.fireHue, saturation: particleState.fireSaturation, brightness: 1)
    }
    
    /// Bridges the existing simple ``Coloring`` enum into the injectable coloring-style backend.
    init(_ coloring: Coloring) {
        switch coloring {
        case .none:
            self = .none
        case .rainbow:
            self = .rainbow
        case .fire:
            self = .fire
        }
    }
}

/// Default renderer that preserves the familiar image/SF Symbol/text fallback.
///
/// This renderer follows the same order as ``ParticleView``: asset image first, SF Symbol second, and text or
/// emoji as the fallback.  It exists so simple call sites and the new renderer API share one backend path.
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
@MainActor
public struct AutomaticParticleRenderer: ParticleRenderer {
    public var content: ParticleContent
    public var coloringStyle: ParticleColoringStyle
    
    /// Creates a renderer from renderer-owned content and the simple coloring enum.
    public init(_ content: ParticleContent = "circle.fill", coloring: Coloring = .none) {
        self.content = content
        self.coloringStyle = ParticleColoringStyle(coloring)
    }
    
    /// Creates a renderer from a custom coloring style.
    public init(_ content: ParticleContent = "circle.fill", coloringStyle: ParticleColoringStyle) {
        self.content = content
        self.coloringStyle = coloringStyle
    }
    
    /// Builds the standard content-backed particle view.
    public func particleView(for context: ParticleRenderingContext) -> ParticleView {
        return ParticleView(
            content: content.value(for: context.particleState),
            particleState: context.particleState,
            coloringStyle: coloringStyle
        )
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension AutomaticParticleRenderer: ParticleContentRenderer {
    /// Rebuilds the automatic renderer with legacy content and optional legacy coloring.
    public func replacingContent(_ content: ParticleContent, coloring: Coloring?) -> Self {
        if let coloring {
            return Self(content, coloring: coloring)
        }
        return Self(content, coloringStyle: coloringStyle)
    }
}

/// Renderer that always treats renderer-owned content as plain SwiftUI text.
@MainActor
public struct TextParticleRenderer: ParticleRenderer {
    public var content: ParticleContent
    public var font: Font
    public var coloringStyle: ParticleColoringStyle
    
    /// Creates a text renderer with optional font and coloring customization.
    public init(_ content: ParticleContent, font: Font = .title, coloring: Coloring = .none) {
        self.content = content
        self.font = font
        self.coloringStyle = ParticleColoringStyle(coloring)
    }
    
    /// Creates a text renderer with a custom coloring style.
    public init(_ content: ParticleContent, font: Font = .title, coloringStyle: ParticleColoringStyle) {
        self.content = content
        self.font = font
        self.coloringStyle = coloringStyle
    }
    
    /// Builds a text particle from the renderer-owned content selected for this particle state.
    public func particleView(for context: ParticleRenderingContext) -> some View {
        Text(content.value(for: context.particleState))
            .font(font)
            .particleAppearance(for: context.particleState, coloringStyle: coloringStyle)
    }
}

extension TextParticleRenderer: ParticleContentRenderer {
    /// Rebuilds the text renderer with legacy content while preserving its font.
    public func replacingContent(_ content: ParticleContent, coloring: Coloring?) -> Self {
        if let coloring {
            return Self(content, font: font, coloring: coloring)
        }
        return Self(content, font: font, coloringStyle: coloringStyle)
    }
}

/// Renderer that treats renderer-owned content as emoji or other text glyphs.
///
/// Emoji rendering is intentionally implemented as a separate type from ``TextParticleRenderer`` even though
/// both use `Text` internally, because `.emoji()` is clearer at call sites and better documents intent.
@MainActor
public struct EmojiParticleRenderer: ParticleRenderer {
    public var content: ParticleContent
    public var font: Font
    
    /// Creates an emoji renderer with renderer-owned content and optional font customization.
    ///
    /// Emoji intentionally does not accept a coloring style because emoji glyphs usually carry their own color.
    public init(_ content: ParticleContent, font: Font = .title) {
        self.content = content
        self.font = font
    }
    
    /// Builds an emoji particle from the renderer-owned content selected for this particle state.
    public func particleView(for context: ParticleRenderingContext) -> some View {
        Text(content.value(for: context.particleState))
            .font(font)
            .particleAppearance(for: context.particleState)
    }
}

extension EmojiParticleRenderer: ParticleContentRenderer {
    /// Rebuilds the emoji renderer with legacy content.
    ///
    /// Emoji ignores legacy coloring for the same reason the normal emoji renderer has no coloring parameter:
    /// emoji glyphs usually carry their own color.
    public func replacingContent(_ content: ParticleContent, coloring: Coloring?) -> Self {
        return Self(content, font: font)
    }
}

/// Renderer that always treats renderer-owned content as an SF Symbol name.
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
@MainActor
public struct SymbolParticleRenderer: ParticleRenderer {
    public var content: ParticleContent
    public var coloringStyle: ParticleColoringStyle
    
    /// Creates an SF Symbol renderer with optional coloring customization.
    public init(_ content: ParticleContent, coloring: Coloring = .none) {
        self.content = content
        self.coloringStyle = ParticleColoringStyle(coloring)
    }
    
    /// Creates an SF Symbol renderer with a custom coloring style.
    public init(_ content: ParticleContent, coloringStyle: ParticleColoringStyle) {
        self.content = content
        self.coloringStyle = coloringStyle
    }
    
    /// Builds an SF Symbol particle from the renderer-owned content selected for this particle state.
    public func particleView(for context: ParticleRenderingContext) -> some View {
        Image(systemName: content.value(for: context.particleState))
            .particleAppearance(for: context.particleState, coloringStyle: coloringStyle)
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension SymbolParticleRenderer: ParticleContentRenderer {
    /// Rebuilds the symbol renderer with legacy content and optional legacy coloring.
    public func replacingContent(_ content: ParticleContent, coloring: Coloring?) -> Self {
        if let coloring {
            return Self(content, coloring: coloring)
        }
        return Self(content, coloringStyle: coloringStyle)
    }
}

/// Renderer that always treats renderer-owned content as an image asset name.
@MainActor
public struct ImageParticleRenderer: ParticleRenderer {
    public var content: ParticleContent
    public var coloringStyle: ParticleColoringStyle
    
    /// Creates an image renderer with optional coloring customization.
    public init(_ content: ParticleContent, coloring: Coloring = .none) {
        self.content = content
        self.coloringStyle = ParticleColoringStyle(coloring)
    }
    
    /// Creates an image renderer with a custom coloring style.
    public init(_ content: ParticleContent, coloringStyle: ParticleColoringStyle) {
        self.content = content
        self.coloringStyle = coloringStyle
    }
    
    /// Builds an image particle from the renderer-owned content selected for this particle state.
    public func particleView(for context: ParticleRenderingContext) -> some View {
        Image(content.value(for: context.particleState))
            .particleAppearance(for: context.particleState, coloringStyle: coloringStyle)
    }
}

extension ImageParticleRenderer: ParticleContentRenderer {
    /// Rebuilds the image renderer with legacy content and optional legacy coloring.
    public func replacingContent(_ content: ParticleContent, coloring: Coloring?) -> Self {
        if let coloring {
            return Self(content, coloring: coloring)
        }
        return Self(content, coloringStyle: coloringStyle)
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public extension ParticleRenderer where Self == AutomaticParticleRenderer {
    /// Preserves the legacy image/SF Symbol/text fallback renderer.
    static func automatic(_ content: ParticleContent = "circle.fill", coloring: Coloring = .none) -> Self {
        return Self(content, coloring: coloring)
    }
    
    /// Preserves the legacy image/SF Symbol/text fallback renderer with a custom coloring style.
    static func automatic(_ content: ParticleContent = "circle.fill", coloringStyle: ParticleColoringStyle) -> Self {
        return Self(content, coloringStyle: coloringStyle)
    }
}

public extension ParticleRenderer where Self == TextParticleRenderer {
    /// Creates a renderer that always displays renderer-owned content as text.
    static func text(_ content: ParticleContent, font: Font = .title, coloring: Coloring = .none) -> Self {
        return Self(content, font: font, coloring: coloring)
    }
    
    /// Creates a text renderer with a custom coloring style.
    static func text(_ content: ParticleContent, font: Font = .title, coloringStyle: ParticleColoringStyle) -> Self {
        return Self(content, font: font, coloringStyle: coloringStyle)
    }
    
    /// Deprecated 1.x helper kept so `renderer: .text()` still compiles while callers move content into `.text("...")`.
    @available(*, deprecated, renamed: "text(_:font:coloring:)", message: "Move the legacy ParticleSystemView string into the renderer, for example `.text(\"Hello World\")`.")
    static func text(font: Font = .title, coloring: Coloring = .none) -> Self {
        return Self("", font: font, coloring: coloring)
    }
}

public extension ParticleRenderer where Self == EmojiParticleRenderer {
    /// Creates a renderer that treats renderer-owned content as emoji.
    static func emoji(_ content: ParticleContent, font: Font = .title) -> Self {
        return Self(content, font: font)
    }
    
    /// Deprecated 1.x helper kept so `renderer: .emoji()` still compiles while callers move content into `.emoji("...")`.
    @available(*, deprecated, renamed: "emoji(_:font:)", message: "Move the legacy ParticleSystemView string into the renderer, for example `.emoji(\"😊,👍\")`.")
    static func emoji(font: Font = .title) -> Self {
        return Self("", font: font)
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public extension ParticleRenderer where Self == SymbolParticleRenderer {
    /// Creates a renderer that always displays renderer-owned content as an SF Symbol.
    static func symbol(_ content: ParticleContent, coloring: Coloring = .none) -> Self {
        return Self(content, coloring: coloring)
    }
    
    /// Creates an SF Symbol renderer with a custom coloring style.
    static func symbol(_ content: ParticleContent, coloringStyle: ParticleColoringStyle) -> Self {
        return Self(content, coloringStyle: coloringStyle)
    }
    
    /// Deprecated 1.x helper kept so `renderer: .symbol(coloring:)` still compiles while callers move content into `.symbol("...")`.
    @available(*, deprecated, renamed: "symbol(_:coloring:)", message: "Move the legacy ParticleSystemView string into the renderer, for example `.symbol(\"star.fill\", coloring: .rainbow)`.")
    static func symbol(coloring: Coloring = .none) -> Self {
        return Self("", coloring: coloring)
    }
}

public extension ParticleRenderer where Self == ImageParticleRenderer {
    /// Creates a renderer that always displays renderer-owned content as an image asset.
    static func image(_ content: ParticleContent, coloring: Coloring = .none) -> Self {
        return Self(content, coloring: coloring)
    }
    
    /// Creates an image renderer with a custom coloring style.
    static func image(_ content: ParticleContent, coloringStyle: ParticleColoringStyle) -> Self {
        return Self(content, coloringStyle: coloringStyle)
    }
    
    /// Deprecated 1.x helper kept so `renderer: .image()` still compiles while callers move content into `.image("...")`.
    @available(*, deprecated, renamed: "image(_:coloring:)", message: "Move the legacy ParticleSystemView string into the renderer, for example `.image(\"ParticleAsset\")`.")
    static func image(coloring: Coloring = .none) -> Self {
        return Self("", coloring: coloring)
    }
}
#endif
