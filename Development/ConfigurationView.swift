//
//  ConfigurationView.swift
//  ParticleEffects
//
//  Created by Ben Ku on 5/4/24.
//

import SwiftUI
import ParticleEffects

struct ConfigurationView: View {
    @Binding var behavior: ParticleBehavior
    @Binding var string: String
    @Binding var coloring: Coloring
    @Binding var showConfiguration: Bool

    var body: some View {
        VStack {
            HStack {
                Picker("Coloring", selection: $coloring ) {
                    ForEach(Coloring.allCases, id: \.self) { item in
                        Text(item.description).tag(item)
                    }
                }.pickerStyle(.segmentedBackport)
                TextField("Particle", text: $string)
#if !os(macOS)
                    .textInputAutocapitalization(.never)
#endif
                Button("😊") {
                    string = "😊,👍,☺️,👏,🙌"
                }
                Button("", systemImage: "flask.fill") {
                    string = "flask.fill"
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
                var normalized = behavior.emissionAngle / 360
                if normalized < 0 {
                    normalized += 1
                }
                return normalized
            }, set: {
                behavior.emissionAngle = $0 * 360
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

#Preview {
    ConfigurationView(behavior: .constant(.bubbles), string: .constant("F,U,N"), coloring: .constant(.rainbow), showConfiguration: .constant(false))
}
