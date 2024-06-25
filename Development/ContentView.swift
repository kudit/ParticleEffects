#if canImport(SwiftUI)
import SwiftUI
import ParticleEffects

struct ContentView: View {
    @StateObject var system = ParticleSystem(behavior: .fountain)
    @State var showConfiguration = false
            
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        VStack {
            if horizontalSizeClass != .compact || verticalSizeClass == .compact {
                HStack {
                    ConfigurationView(behavior: $system.behavior, showConfiguration: $showConfiguration)
                    DraggableParticleSystemView(particleSystem: system, background: .black)
                        .font(.largeTitle)
                        .ignoresSafeArea()
                }
            } else {
                ConfigurationView(behavior: $system.behavior, showConfiguration: $showConfiguration)
                DraggableParticleSystemView(particleSystem: system, background: .black)
                    .font(.largeTitle)
                    .ignoresSafeArea()
            }
        }
        #if !os(watchOS) && !os(tvOS)
        .sheet(isPresented: $showConfiguration) {
            Button("Dismiss") {
                showConfiguration = false
            }.buttonStyle(.bordered)
            TextEditor(text: Binding(get: {
                system.behavior.code
            }, set: { _,_ in 
                // do nothing
            }))
        }
        #endif
    }
}
#endif
