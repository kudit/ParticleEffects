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
                ParticleSystemView(behavior: .bubbles.modified(string: "globe", blur: Blur.none, coloring: .rainbow))
                    .imageScale(.large)
                    .frame(width: 200, height: 200)
            }
        Text("Demo")
    }
}

#if swift(>=5.9)
// README examples
#Preview("Demo") {
    SimpleDemoView()
}

#Preview("Fire") {
    ParticleSystemView(behavior: .fire)
        .font(.largeTitle)
        .aspectRatio(contentMode: .fit)
}

#Preview("Sun") {
    ParticleSystemView(behavior:
            .sun.modified(
                string: "star.fill",
                birthRate: .frequent,
                blur: Blur.none,
                coloring: .rainbow
            )
    )
    .aspectRatio(contentMode: .fit)
}

#Preview("Emoji") {
    ParticleSystemView(behavior: .fountain, string: "😊,👍,☺️,👏,🙌")
    .aspectRatio(contentMode: .fit)
}
#endif
#endif
