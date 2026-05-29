//
//  SimpleDemoView.swift
//  ParticleEffects
//
//  Created by Ben Ku on 5/8/24.
//

#if canImport(SwiftUI)
import SwiftUI
import ParticleEffects

struct SimpleDemoView: View {
    var body: some View {
        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundColor(.accentColor)
            .overlay {
                ParticleSystemView(behavior: .bubbles.modified(blur: Blur.none), renderer: .symbol("globe", coloring: .rainbow))
                    .imageScale(.large)
                    .frame(width: 200, height: 200)
            }
        Text("Demo")
    }
}

/// Demo renderer showing how an app can supply any SwiftUI view as a particle.
///
/// The renderer reads from the generic render context and then opts into the standard particle appearance
/// modifier so opacity, blur, rotation, and coloring stay consistent with the built-in renderers.
private struct TokenParticleRenderer: ParticleRenderer {
    /// Renderer-owned content used to label token particles without storing that label in the particle model.
    private let content: ParticleContent = "K,U,D,I,T"
    
    func particleView(for context: ParticleRenderingContext) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.green.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                )
            Text(content.value(for: context.state))
                .font(.caption.bold())
                .foregroundStyle(.primary)
        }
        .frame(width: 44, height: 28)
        .particleAppearance(for: context.state, coloring: .rainbow)
    }
}

#if swift(>=5.9)
// README examples
#Preview("Demo") {
    SimpleDemoView()
}

#Preview("Fire") {
    ParticleSystemView(behavior: .fire, renderer: .symbol("drop.fill", coloring: .fire))
        .font(.largeTitle)
        .aspectRatio(contentMode: .fit)
}

#Preview("Sun") {
    ParticleSystemView(
        behavior: .sun.modified(
            birthRate: .frequent,
            blur: Blur.none
        ),
        renderer: .symbol("star.fill", coloring: .rainbow)
    )
    .aspectRatio(contentMode: .fit)
}

#Preview("Emoji") {
    ParticleSystemView(behavior: .fountain, renderer: .emoji("😊,👍,☺️,👏,🙌"))
    .aspectRatio(contentMode: .fit)
}

#Preview("Custom Renderer") {
    ParticleSystemView(
        behavior: .sparkle.modified(spin: .medium),
        renderer: TokenParticleRenderer()
    )
    .aspectRatio(contentMode: .fit)
}
#endif
#endif
