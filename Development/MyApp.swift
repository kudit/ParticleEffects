import SwiftUI
import ParticleEffects

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
#if os(watchOS) || os(tvOS)
                ScrollView {
                    ContentView()
                }
#else
                ContentView()
#endif
                Text("ParticleEffects v\(ParticleEffects.version) © 2024 Kudit LLC").font(.caption).padding().foregroundStyle(.white)
            }
        }
    }
}
