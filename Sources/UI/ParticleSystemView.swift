#if canImport(SwiftUI)
import SwiftUI

public extension Vector {
    func cgPoint(_ size: CGSize) -> CGPoint {
        return CGPoint(x: x * size.width, y: y * size.height)
    }
}

@MainActor
public struct ParticleSystemView<SomeParticleView: View>: View {
    public var particleSystem: ParticleSystem
    public typealias ParticleViewGenerator = (Particle, ParticleSystem) -> SomeParticleView
    public var particleView: ParticleViewGenerator

    public init(particleSystem: ParticleSystem, particleView: @escaping ParticleViewGenerator) {
        self.particleSystem = particleSystem
        self.particleView = particleView
    }
    
    #warning("Figure out why we can't just use a timer and have the timeline view just read the particles (or not even be used?)")
    public var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                ForEach(particleSystem.particles(for: timeline.date.timeIntervalSinceReferenceDate), id: \.self) { particle in
                    particleView(particle, particleSystem)
                        .position(particle.position.cgPoint(proxy.size))
                }
            }
        }
    }
}
extension ParticleSystemView where SomeParticleView == ParticleView {
    public init(particleSystem: ParticleSystem) {
        self.init(particleSystem: particleSystem) { particle, particleSystem in
            ParticleView(particle: particle, coloring: particleSystem.behavior.coloring)
        }
    }
}

#if swift(>=5.9)
#Preview("Confetti Demo") {
    let behavior = ParticleBehavior(
        string: "😊,👍,☺️,👏,🙌",
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
        ParticleSystemView(particleSystem: .init(behavior: behavior))
        Color.clear
    }
}

#Preview("Fire Example") {
    ParticleSystemView(particleSystem: .init(behavior: .fire.modified(string: "drop.fill")))
}

struct TestAnimatedParticleView: View {
    @StateObject var particleSystem = ParticleSystem(center: .leading, behavior: .init(
        string: "star.fill",
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

#Preview("Red") {
    // TODO: do test where it traces a path like a triangle?
    ZStack {
        Color.gray
        TestAnimatedParticleView(particleSystem: .init(
            behavior: .sun.modified(string: "square.fill")
        ))
        TestAnimatedParticleView(particleSystem: .init(
            behavior: .fountain.modified(string: "drop.fill")))
            .frame(width: 100, height: 200)
            .border(.green, width: 5)
            .background(.black)
            .foregroundStyle(.blue)
        TestAnimatedParticleView()
            .aspectRatio(contentMode: .fit)
//            .border(.red, width: 5)
    }.ignoresSafeArea()
}
#endif
#endif
