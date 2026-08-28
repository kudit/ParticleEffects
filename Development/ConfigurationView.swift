//
//  ConfigurationView.swift
//  ParticleEffects
//
//  Created by Ben Ku on 5/4/24.
//

#if canImport(SwiftUI)
import SwiftUI
import ParticleEffects
import Compatibility

struct ConfigurationView: View {
    @Binding var behavior: ParticleBehavior
    @Binding var controlMode: DemoEmitterControlMode
    @Binding var rendererMode: DemoRendererMode
    @Binding var shapeMode: DemoShapeMode
    @Binding var particleContent: String
    @Binding var solidColor: Color
    @Binding var coloring: Coloring
    @Binding var toggleParticleValue: Bool
    @Binding var showConfiguration: Bool

    var body: some View {
        VStack(alignment: .leading) {
            configurationSection("Control") {
                controlControls
            }
            configurationSection("Content") {
                VStack(alignment: .leading) {
                    contentControls
                }
            }
            configurationSection("Coloring") {
                Picker("Coloring", selection: $coloring ) {
                    ForEach(Coloring.allCases, id: \.self) { item in
                        Text(item.description).tag(item)
                    }
                }.pickerStyle(.segmentedBackport)
                if coloring == .none {
#if os(watchOS) || os(tvOS)
                    Text("Solid Color")
                        .font(.caption)
                        .foregroundStyle(.secondary)
#else
                    ColorPicker("Color", selection: $solidColor)
#endif
                }
            }
            configurationSection("Behavior") {
                behaviorControls
            }
        }
    }
    
    /// Presents a titled configuration area using the best container available on the current platform.
    ///
    /// `GroupBox` gives the requested section grouping on macOS, iOS, tvOS, and visionOS, but SwiftUI marks it
    /// unavailable on watchOS.  The watchOS fallback keeps the same information architecture with a lightweight
    /// labeled stack so the shared development view can still compile for the companion app target.
    @ViewBuilder
    private func configurationSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
#if os(watchOS)
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
#else
        Backport.GroupBox(title) {
            content()
        }
#endif
    }
    
    /// Controls how the emitter center is driven and exposes the generated configuration command.
    ///
    /// Keeping this separate from content makes the demo clearer: dragging and path-following are system
    /// control concerns, while the renderer selection below only changes what each particle looks like.
    private var controlControls: some View {
        VStack(alignment: .leading) {
            Picker("Control", selection: $controlMode) {
                ForEach(DemoEmitterControlMode.allCases) { item in
                    Text(item.label).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
#if !os(watchOS) && !os(tvOS)
            Button("View Configuration") {
                showConfiguration = true
            }
#endif
        }
    }
    
    /// Controls the renderer content independently from the particle behavior.
    ///
    /// Presets intentionally set both behavior and renderer configuration so each named effect remains a
    /// complete example even though v2 keeps motion and rendering separated internally.
    private var contentControls: some View {
        VStack(alignment: .leading) {
            Picker("Presets", selection: Binding(get: {
                behavior
            }, set: {
                applyPreset($0)
            })) {
                ForEach(ParticleBehavior.presets, id: \.self) { item in
                    Text(item.label).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            Picker("Renderer", selection: Binding(get: {
                rendererMode
            }, set: {
                selectRendererMode($0)
            })) {
                ForEach(DemoRendererMode.allCases) { item in
                    Text(item.label).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
            if rendererMode == .shape {
                Picker("Shape", selection: $shapeMode) {
                    ForEach(DemoShapeMode.allCases) { item in
                        Text(item.label).tag(item)
                    }
                }.pickerStyle(.segmentedBackport)
            } else if rendererMode != .toggle {
                TextField("Particle", text: $particleContent)
#if !os(macOS)
                    .textInputAutocapitalization(.never)
#endif
            }
        }
    }
    
    /// Applies one of the named demo presets to both behavior and renderer state.
    private func applyPreset(_ preset: ParticleBehavior) {
        behavior = preset
        switch preset.label {
        case ParticleBehavior.rain.label:
            rendererMode = .symbol
            particleContent = "drop.fill"
            coloring = .none
            solidColor = .blue
        case ParticleBehavior.fountain.label:
            rendererMode = .automatic
            particleContent = "😊,👍,☺️,👏,🙌"
            coloring = .none
            solidColor = .white
        case ParticleBehavior.bubbles.label:
            rendererMode = .symbol
            particleContent = "circle"
            coloring = .rainbow
            solidColor = .cyan
        case ParticleBehavior.smoke.label:
            rendererMode = .automatic
            particleContent = "circle.fill"
            coloring = .none
            solidColor = .white
        case ParticleBehavior.fire.label:
            rendererMode = .symbol
            particleContent = "drop.fill"
            coloring = .fire
            solidColor = .orange
        case ParticleBehavior.sparkle.label:
            rendererMode = .symbol
            particleContent = "sparkle"
            coloring = .rainbow
            solidColor = .yellow
        case ParticleBehavior.sun.label:
            rendererMode = .symbol
            particleContent = "star.fill"
            coloring = .fire
            solidColor = .yellow
        default:
            break
        }
    }
    
    /// Applies renderer-specific defaults when the renderer segment changes.
    private func selectRendererMode(_ mode: DemoRendererMode) {
        rendererMode = mode
        switch mode {
        case .automatic:
            particleContent = particleContent.isEmpty ? "circle.fill" : particleContent
        case .text:
            particleContent = "Hello World"
        case .symbol:
            particleContent = "flask.fill"
        case .shape:
            shapeMode = .placard
        case .toggle:
            particleContent = ""
            toggleParticleValue = true
        }
    }
    
    /// Controls behavior-only values such as birth rate, lifetime, physics, and spin.
    ///
    /// Renderer content and coloring live in the other sections so the demo mirrors the v2 API split between
    /// particle motion and particle rendering.
    private var behaviorControls: some View {
        VStack {
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
            Picker("Spin", selection: $behavior.spin) {
                ForEach(Spin.allCases, id: \.self) { item in
                    Text(String(describing: item)).tag(item)
                }
            }.pickerStyle(.segmentedBackport)
        }
    }
}

#if swift(>=5.9)
#Preview {
    List {
        ConfigurationView(behavior: .constant(.bubbles), controlMode: .constant(.drag), rendererMode: .constant(.symbol), shapeMode: .constant(.circle), particleContent: .constant("circle"), solidColor: .constant(.cyan), coloring: .constant(.rainbow), toggleParticleValue: .constant(true), showConfiguration: .constant(false))
        ConfigurationView(behavior: .constant(.rain), controlMode: .constant(.followShape), rendererMode: .constant(.symbol), shapeMode: .constant(.triangle), particleContent: .constant("drop.fill"), solidColor: .constant(.blue), coloring: .constant(.none), toggleParticleValue: .constant(true), showConfiguration: .constant(false))
        ConfigurationView(behavior: .constant(.sparkle), controlMode: .constant(.drag), rendererMode: .constant(.text), shapeMode: .constant(.placard), particleContent: .constant("F,U,N"), solidColor: .constant(.white), coloring: .constant(.rainbow), toggleParticleValue: .constant(true), showConfiguration: .constant(false))
    }
}
#endif
#endif
