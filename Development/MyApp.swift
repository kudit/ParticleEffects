#if canImport(SwiftUI)
import Compatibility
import SwiftUI
#if canImport(ParticleEffects) // since this is needed in XCode but is unavailable in Playgrounds.
import ParticleEffects
#endif

@available(iOS 15.0, macOS 12, tvOS 17, watchOS 8, *)
@main
struct MyApp: App {
    /// Registers the app's highest-level package module before support reporting begins.
    init() {
        // ParticleEffects declares Compatibility as a dependency, so recursive registration includes both modules.
        Application.track(ParticleEffects.self)
    }

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
                Text("ParticleEffects v\(ParticleEffects.version) © \(Date.now.year.string) Kudit LLC").font(.caption).padding().foregroundStyle(.white)
            }
        }
    }
}
#endif
