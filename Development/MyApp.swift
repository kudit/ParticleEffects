#if canImport(SwiftUI)
import Compatibility
import SwiftUI
#if canImport(ParticleEffects) // since this is needed in XCode but is unavailable in Playgrounds.
import ParticleEffects
#endif

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
@main
struct MyApp: App {
    /// Registers the app's highest-level package module before support reporting begins.
    init() {
        // ParticleEffects declares Compatibility as a dependency, so recursive registration includes both modules.
        // UI tests run without an iCloud container entitlement; keep their version tracking local instead of
        // probing the macOS security/iCloud services during app startup.
        if ProcessInfo.processInfo.environment["TESTING"] == "1" {
            Application.iCloudSupported = false
        }
        Application.track(ParticleEffects.self)
    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
#if os(watchOS)
                ScrollView {
                    ContentView()
                }
#else
                // ContentView contains its own scrolling configuration panel.  Wrapping the complete tvOS
                // root in another vertical ScrollView would give GeometryReader an unbounded height proposal,
                // causing the particle surface's percentage-based layout to collapse into a short strip.
                ContentView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
#endif
                Text("ParticleEffects v\(ParticleEffects.version) © \(Date.nowBackport.year.string) Kudit LLC").font(.caption).padding().backport.foregroundStyle(.white)
            }
        }
    }
}
#endif
