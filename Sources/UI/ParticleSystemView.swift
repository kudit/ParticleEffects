#if canImport(SwiftUI)
import SwiftUI

public extension Vector {
    func cgPoint(_ size: CGSize) -> CGPoint {
        return CGPoint(x: x * size.width, y: y * size.height)
    }
}

public struct ParticleSystemView<ParticleView: View & ParticleConfiguration>: View {
    public var particleSystem: ParticleSystem<ParticleView>
    /// For new configurations
    public var particleView: () -> ParticleView
    
    public init(particleSystem: ParticleSystem<ParticleView>, particleView: @escaping () -> ParticleView) {
        self.particleSystem = particleSystem
        self.particleView = particleView
    }
            
    public var body: some View {
        TimelineView(.animation) { timeline in
            let _ = {
                // add new particles and modify existing particle positions
                particleSystem.update(at: timeline.date.timeIntervalSinceReferenceDate, configuration: particleView)
            }()
            GeometryReader { proxy in
//                Text("\(timeline.date.timeIntervalSinceReferenceDate)").font(.caption)
                ForEach(particleSystem.particles, id: \.self) { particle in
                    // TODO: If we need to inject changes to hue or other configurations, do it here
                    particle.configuration
                        .position(particle.position.cgPoint(proxy.size))
                        .opacity(particle.opacity)
                        .blur(radius: particle.blur)
                }
            }
        }
    }
}
extension ParticleSystemView where ParticleView == StringConfiguration {
    public init(particleSystem: ParticleSystem<ParticleView>, string: String = "Hello,World", coloring: Coloring = .none) {
        self.init(particleSystem: particleSystem) {
            StringConfiguration(string: string, coloring: coloring)
        }
    }
    public init(behavior: ParticleBehavior = .fountain, string: String = "Hello,World", coloring: Coloring = .none) {
        self.init(particleSystem: ParticleSystem(behavior: behavior), string: string, coloring: coloring)
    }
}

#if swift(>=5.9)
struct TestAnimatedParticleView: View {
    var particleSystem = ParticleSystem<StringConfiguration>(center: .leading, behavior: ParticleBehavior(
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
        TimelineView(.animation) { context in
            let _ = {
                let pos = (sin(context.date.timeIntervalSinceReferenceDate) + 1) / 2
                self.particleSystem.center.x = pos
            }()
            ParticleSystemView(particleSystem: particleSystem, string: "star.fill", coloring: .none)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    // TODO: do test where it traces a path like a triangle?
    ZStack {
        Color.gray
        ParticleSystemView(particleSystem: ParticleSystem(
            behavior: .sun
        )) { StringConfiguration(string: "square.fill") }//.aspectRatio(contentMode: .fit)
        ParticleSystemView(particleSystem: ParticleSystem(
            behavior: .fountain
        )) { StringConfiguration(string: "drop.fill") }
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
