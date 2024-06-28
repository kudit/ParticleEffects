#if canImport(SwiftUI)
import SwiftUI
import ParticleEffects

struct DraggableParticleSystemView: View {
    @ObservedObject public var particleSystem: ParticleSystem
    public var background: Color // necessary for drag view to be draggable and not just shapes
    
    var body: some View {
        GeometryReader { proxy in
            background
#if !os(tvOS)
                .gesture (
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            particleSystem.center.x = drag.location.x / proxy.size.width
                            particleSystem.center.y = drag.location.y / proxy.size.height
                        }
                )
#endif
            ParticleSystemView(particleSystem: particleSystem)
            .allowsHitTesting(false)
            .foregroundStyle(.white) // make sure light mode doesn't make invisible.
        }
    }
}
#endif
