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
                ParticleSystemView(particleSystem: .init(behavior: .bubbles.modified(string: "globe", blur: Blur.none, coloring: .rainbow)))
                    .imageScale(.large)
                    .frame(width: 200, height: 200)
            }
        Text("Demo")
    }
}

#if swift(>=5.9)
#Preview {
    SimpleDemoView()
}
#endif
#endif
