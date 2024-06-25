//
//  ConfigurationView.swift
//  ParticleEffects
//
//  Created by Ben Ku on 5/4/24.
//

#if canImport(SwiftUI)
import SwiftUI
import ParticleEffects

struct ConfigurationView: View {
    @Binding var behavior: ParticleBehavior
    @Binding var showConfiguration: Bool

    var body: some View {
        VStack {
            HStack {
                Picker("Coloring", selection: $behavior.coloring ) {
                    ForEach(Coloring.allCases, id: \.self) { item in
                        Text(item.description).tag(item)
                    }
                }.pickerStyle(.segmentedBackport)
                TextField("Particle", text: $behavior.string)
#if !os(macOS)
                    .textInputAutocapitalization(.never)
#endif
                Button("😊") {
                    behavior.string = "😊,👍,☺️,👏,🙌"
                }
                Button("", systemImage: "flask.fill") {
                    behavior.string = "flask.fill"
                }
#if !os(watchOS) && !os(tvOS)
                Button("Configuration") {
                    showConfiguration = true
                }
#endif
            }
            Picker("Presets", selection: Binding(get: {
                behavior
            }, set: {
                behavior = $0
            })) {
                ForEach(ParticleBehavior.presets, id: \.self) { item in
                    Text(item.label).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Birth Rate", selection: $behavior.birthRate) {
                ForEach(BirthRate.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Lifetime", selection: $behavior.lifetime) {
                ForEach(Lifetime.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Fade Out", selection: $behavior.fadeOut) {
                ForEach(FadeOut.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            #if !os(tvOS)
            Slider(value: Binding(get: {
                var normalized = behavior.emissionAngle.rawValue / 360
                if normalized < 0 {
                    normalized += 1
                }
                return normalized
            }, set: {
                behavior.emissionAngle = Degrees(floatLiteral: $0 * 360)
            }))
            #endif
            Picker("Spread", selection: $behavior.spread) {
                ForEach(SpreadArc.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Initial Velocity", selection: $behavior.initialVelocity) {
                ForEach(InitialVelocity.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Acceleration", selection: $behavior.acceleration) {
                ForEach(Acceleration.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Blur", selection: $behavior.blur) {
                ForEach(Blur.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
        }
    }
}

#if swift(>=5.9)
#Preview {
    List {
        ConfigurationView(behavior: .constant(.bubbles), showConfiguration: .constant(false))
        ConfigurationView(behavior: .constant(.rain), showConfiguration: .constant(false))
        ConfigurationView(behavior: .constant(.sparkle), showConfiguration: .constant(false))
        ConfigurationView(behavior: .constant(.init(string: "F,U,N", coloring: .rainbow)), showConfiguration: .constant(false))
    }
}
#endif
#endif
