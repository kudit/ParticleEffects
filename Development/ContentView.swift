#if canImport(SwiftUI)
import SwiftUI
import ParticleEffects



struct ContentView: View {
    @State public var string = "star.fill"
    
    @State var behavior: ParticleBehavior = .fountain
    @State var showConfiguration = false
    @State var coloring: Coloring = .rainbow
            
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        VStack {
            if horizontalSizeClass != .compact || verticalSizeClass == .compact {
                HStack {
                    ConfigurationView(behavior: $behavior, string: $string, coloring: $coloring, showConfiguration: $showConfiguration)
                    DraggableParticleSystemView(particleSystem: ParticleSystem(behavior: behavior), background: .black, string: string, coloring: coloring).tag(string)
                        .font(.largeTitle)
                        .ignoresSafeArea()
                }
            } else {
                ConfigurationView(behavior: $behavior, string: $string, coloring: $coloring, showConfiguration: $showConfiguration)
                DraggableParticleSystemView(particleSystem: ParticleSystem(behavior: behavior), background: .black, string: string, coloring: coloring).tag(string)
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
                behavior.code
            }, set: { _,_ in 
                // do nothing
            }))
        }
        #endif
    }
}
#endif
