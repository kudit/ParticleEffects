import SwiftUI
import ParticleEffects

struct DraggableParticleSystemView: View {
    public var particleSystem: ParticleSystem<StringConfiguration>
    public var background: Color // necessary for drag view to be draggable and not just shapes
    public var string = "circle"
    public var coloring: Coloring
    
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
            ParticleSystemView(particleSystem: particleSystem) {
                StringConfiguration(string: string, coloring: coloring)
            }
            .allowsHitTesting(false)
        }
    }
}
