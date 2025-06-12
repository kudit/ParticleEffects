#if canImport(SwiftUI)
import SwiftUI
#if canImport(ParticleEffects) // since this is needed in XCode but is unavailable in Playgrounds.
import ParticleEffects
#endif

@available(iOS 15.0, macOS 12, tvOS 17, watchOS 8, *)
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
#endif
