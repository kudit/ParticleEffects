#if canImport(SwiftUI)
import SwiftUI

public extension Vector {
    func cgPoint(_ size: CGSize) -> CGPoint {
        return CGPoint(x: x * size.width, y: y * size.height)
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
@MainActor
public struct ParticleSystemView<SomeParticleView: View>: View {
    public var particleSystem: ParticleSystem
    public typealias ParticleViewGenerator = (ParticleState, ParticleSystem) -> SomeParticleView
    public typealias ParticleContextViewGenerator = (ParticleRenderingContext) -> SomeParticleView
    public var particleView: ParticleContextViewGenerator

    /// Creates a particle system view with a renderer that receives the full render context.
    ///
    /// This is the most flexible closure-based initializer because the renderer receives particle state,
    /// system configuration, geometry, and timeline time in one value.
    public init(particleSystem: ParticleSystem, particleView: @escaping ParticleContextViewGenerator) {
        self.particleSystem = particleSystem
        self.particleView = particleView
    }
    
    /// Creates a particle system view with the original state-and-system closure shape.
    ///
    /// Existing code can continue to use this initializer.  Internally it is bridged into the newer render
    /// context so the old API and the renderer API share the same backend path.
    public init(particleSystem: ParticleSystem, particleView: @escaping ParticleViewGenerator) {
        self.particleSystem = particleSystem
        self.particleView = { context in
            particleView(context.particleState, context.particleSystem)
        }
    }
    
    /// Creates a particle system view from a reusable renderer value.
    ///
    /// Named renderers are the recommended path for reusable custom particles because they can document their
    /// own configuration while still using the generic render context.
    public init<Renderer: ParticleRenderer>(
        particleSystem: ParticleSystem,
        renderer: Renderer
    ) where SomeParticleView == Renderer.ParticleBody {
        self.init(particleSystem: particleSystem) { context in
            renderer.particleView(for: context)
        }
    }
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let currentTime = timeline.date.timeIntervalSinceReferenceDate
                ForEach(particleSystem.particles(for: currentTime), id: \.particle) { particleState in
                    // The renderer owns particle content while this view owns layout.  Keeping positioning
                    // here means image, text, shape, and fully custom SwiftUI renderers all share the same
                    // physics output from the behavior system.
                    particleView(ParticleRenderingContext(
                        particleState: particleState,
                        particleSystem: particleSystem,
                        geometry: proxy,
                        currentTime: currentTime
                    ))
                        .position(particleState.position.cgPoint(proxy.size))
                }
            }
        }
    }
}
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension ParticleSystemView where SomeParticleView == ParticleView {
    public init(particleSystem: ParticleSystem) {
        self.init(particleSystem: particleSystem, renderer: AutomaticParticleRenderer())
    }
    // convenience for creating a single-use system.
    public init(behavior: ParticleBehavior = .fountain) {
        self.init(particleSystem: ParticleSystem(behavior: behavior))
    }
    
    /// Deprecated 1.x convenience initializer.
    ///
    /// This keeps older `ParticleSystemView(behavior:string:coloring:)` call sites compiling while making the
    /// migration clear: content now belongs in the renderer instead of the behavior or system initializer.
    @available(*, deprecated, renamed: "init(behavior:renderer:)", message: "Move `string:` into the renderer, for example `ParticleSystemView(behavior: behavior, renderer: .automatic(\"star.fill\", coloring: .rainbow))`.")
    public init(
        behavior: ParticleBehavior = .fountain,
        string: String,
        coloring: Coloring? = nil
    ) {
        self.init(
            behavior: behavior,
            renderer: AutomaticParticleRenderer(
                ParticleContent(string),
                coloring: coloring ?? .none
            )
        )
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public extension ParticleSystemView {
    /// Creates a single-use particle system view using a reusable renderer value.
    ///
    /// This mirrors the existing convenience initializer and makes the simple API a shorthand over the more
    /// powerful renderer backend.
    init<Renderer: ParticleRenderer>(
        behavior: ParticleBehavior = .fountain,
        renderer: Renderer
    ) where SomeParticleView == Renderer.ParticleBody {
        self.init(
            particleSystem: ParticleSystem(behavior: behavior),
            renderer: renderer
        )
    }
    
    /// Deprecated 1.x renderer initializer.
    ///
    /// The legacy form supplied display content through `string:` and a renderer like `.emoji()`.  The v2 API
    /// stores content in the renderer itself, but this shim copies the legacy string into built-in renderers so
    /// existing source keeps working while Xcode can guide the caller toward the new call shape.
    @available(*, deprecated, renamed: "init(behavior:renderer:)", message: "Move `string:` into the renderer, for example `ParticleSystemView(behavior: behavior, renderer: .emoji(\"😊,👍\"))`.")
    init<Renderer: ParticleContentRenderer>(
        behavior: ParticleBehavior = .fountain,
        string: String,
        coloring: Coloring? = nil,
        renderer: Renderer
    ) where SomeParticleView == Renderer.ParticleBody {
        let migratedRenderer = renderer.replacingContent(
            ParticleContent(string),
            coloring: coloring
        )
        self.init(behavior: behavior, renderer: migratedRenderer)
    }
}

#if swift(>=5.9)
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
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
        ParticleSystemView(particleSystem: .init(behavior: behavior), renderer: .emoji("😊,👍,☺️,👏,🙌"))
        Color.clear
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
#Preview("Fire Example") {
    ParticleSystemView(particleSystem: .init(behavior: .fire), renderer: .symbol("drop.fill", coloring: .fire))
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
#Preview("Emoji Renderer Example") {
    ParticleSystemView(behavior: .fountain, renderer: .emoji("😊,👍,☺️"))
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
#Preview("Custom Renderer Example") {
    ParticleSystemView(
        behavior: .sparkle.modified(spin: .medium),
        renderer: CustomParticleRenderer { context in
            Text(["K", "U", "D", "I", "T"][context.particle.index % 5])
                .font(.caption.bold())
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.2)))
                .particleAppearance(for: context.state, coloring: .rainbow)
                .border(.green, width: 5)
        }
    )
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
struct TestAnimatedParticleView: View {
    @StateObject var particleSystem = ParticleSystem(center: .leading, behavior: .init(
        birthRate: .frequent,
        lifetime: .brief,
        fadeOut: .lengthy,
        emissionAngle: .top,
        spread: .complete,
        initialVelocity: .slow,
        acceleration: .sun,
        blur: .none
    ))
    
    var body: some View {
        VStack {
            ParticleSystemView(particleSystem: particleSystem)
                .border(.red, width: 4)
            Text("Count: \(particleSystem.particles.count)")
        }
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
#Preview("Red") {
    // TODO: do test where it traces a path like a triangle?
    ZStack {
        Color.gray
        TestAnimatedParticleView(particleSystem: .init(
            behavior: .sun
        ))
        TestAnimatedParticleView(particleSystem: .init(
            behavior: .fountain))
            .frame(width: 100, height: 200)
            .border(.green, width: 5)
            .backport.background(.black)
            .backport.foregroundStyle(.blue)
        TestAnimatedParticleView()
            .aspectRatio(contentMode: .fit)
//            .border(.red, width: 5)
    }.ignoresSafeArea()
}
#endif
#endif
