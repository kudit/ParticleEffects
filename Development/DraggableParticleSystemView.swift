#if canImport(SwiftUI)
import ParticleEffects
import SwiftUI

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
struct DraggableParticleSystemView<ParticleLayer: View>: View {
    @ObservedObject public var particleSystem: ParticleSystem
    public var background: Color // necessary for drag view to be draggable and not just shapes
    public var allowsParticleInteraction: Bool
    public var particleLayer: () -> ParticleLayer
    
    /// Creates a draggable emitter surface with an injected particle layer.
    ///
    /// The particle layer is supplied by the demo instead of being hard-coded so the same surface can show the
    /// v2 renderer examples, including interactive SwiftUI controls.
    init(
        particleSystem: ParticleSystem,
        background: Color,
        allowsParticleInteraction: Bool = false,
        @ViewBuilder particleLayer: @escaping () -> ParticleLayer
    ) {
        self.particleSystem = particleSystem
        self.background = background
        self.allowsParticleInteraction = allowsParticleInteraction
        self.particleLayer = particleLayer
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background
#if !os(tvOS)
                    .contentShape(Rectangle())
                    .gesture (
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in
                                // Convert the drag location into the normalized unit-space center used by the
                                // particle system so behavior physics can stay independent from the view size.
                                particleSystem.center.x = drag.location.x / proxy.size.width
                                particleSystem.center.y = drag.location.y / proxy.size.height
                            }
                    )
#endif
                particleLayer()
                    .allowsHitTesting(allowsParticleInteraction)
                    .foregroundStyle(.white) // make sure light mode doesn't make invisible.
            }
        }
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension DraggableParticleSystemView where ParticleLayer == ParticleSystemView<ParticleView> {
    /// Preserves the simple development-app call site for the default automatic renderer.
    init(particleSystem: ParticleSystem, background: Color, allowsParticleInteraction: Bool = false) {
        self.init(
            particleSystem: particleSystem,
            background: background,
            allowsParticleInteraction: allowsParticleInteraction
        ) {
            ParticleSystemView(particleSystem: particleSystem)
        }
    }
}
#endif
