#if canImport(SwiftUI)
import Compatibility
import SwiftUI
import ParticleEffects

enum DemoEmitterControlMode: String, CaseIterable, Identifiable {
    case drag, followShape
    
    var id: Self {
        return self
    }
    
    /// Short label for the segmented control that chooses how the emitter center is driven.
    var label: String {
        switch self {
        case .drag:
            return "Drag"
        case .followShape:
            return "Follow Shape"
        }
    }
}

enum DemoRendererMode: String, CaseIterable, Identifiable {
    case automatic, text, symbol, shape, toggle
    
    var id: Self {
        return self
    }
    
    /// Short label used in the demo picker.
    ///
    /// The renderer mode is development-app state only; production callers can pass any renderer directly to
    /// `ParticleSystemView`.
    var label: String {
        switch self {
        case .automatic:
            return "Auto"
        case .text:
            return "Text"
        case .symbol:
            return "Symbol"
        case .shape:
            return "Shape"
        case .toggle:
            return "Toggle"
        }
    }
}

enum DemoShapeMode: String, CaseIterable, Identifiable {
    case circle, square, triangle, placard
    
    var id: Self {
        return self
    }
    
    /// Short label for shape particles in the content configuration section.
    var label: String {
        switch self {
        case .circle:
            return "Circle"
        case .square:
            return "Square"
        case .triangle:
            return "Triangle"
        case .placard:
            return "Placard"
        }
    }
}

struct ContentView: View {
    @StateObject var system = ParticleSystem(behavior: .fountain)
    @State var controlMode: DemoEmitterControlMode = .drag
    @State var rendererMode: DemoRendererMode = .automatic
    @State var shapeMode: DemoShapeMode = .placard
    @State var particleContent = "😊,👍,☺️,👏,🙌"
    @State var solidColor = Color.white
    @State var coloring = Coloring.none
    @State var toggleParticleValue = true
    @State var showConfiguration = false
            
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        VStack {
            if horizontalSizeClass != .compact || verticalSizeClass == .compact {
                HStack {
                    configuration
                    demoSurface
                }
            } else {
                configuration
                demoSurface
            }
        }
        #if !os(watchOS) && !os(tvOS)
        .sheet(isPresented: $showConfiguration) {
            Button("Dismiss") {
                showConfiguration = false
            }.buttonStyle(.bordered)
            TextEditor(text: Binding(get: {
                demoConfigurationCode
            }, set: { _,_ in 
                // do nothing
            }))
        }
        #endif
    }
    
    /// The demo configuration panel is split to mirror the v2 API: renderer content, coloring, and behavior.
    private var configuration: some View {
        ConfigurationView(
            behavior: $system.behavior,
            controlMode: $controlMode,
            rendererMode: $rendererMode,
            shapeMode: $shapeMode,
            particleContent: $particleContent,
            solidColor: $solidColor,
            coloring: $coloring,
            toggleParticleValue: $toggleParticleValue,
            showConfiguration: $showConfiguration
        )
    }
    
    /// Chooses between a draggable emitter and the triangle-path emitter demo.
    ///
    /// The particle layer is injected so both surfaces can host the same renderer examples, including the
    /// interactive Toggle renderer where hit testing needs to stay enabled.
    private var demoSurface: some View {
        Group {
            if controlMode == .followShape {
                TrianglePathParticleSystemView(
                    particleSystem: system,
                    background: .black,
                    allowsParticleInteraction: rendererMode == .toggle
                ) {
                    particleLayer
                }
            } else {
                DraggableParticleSystemView(
                    particleSystem: system,
                    background: .black,
                    allowsParticleInteraction: rendererMode == .toggle
                ) {
                    particleLayer
                }
            }
        }
        .font(.largeTitle)
        .ignoresSafeArea()
    }
    
    /// Builds the currently selected renderer demo.
    ///
    /// Each renderer owns the content it uses for display.  The shared particle system only supplies particle
    /// lifetime, position, and behavior state.
    @ViewBuilder
    private var particleLayer: some View {
        switch rendererMode {
        case .automatic:
            if automaticContentUsesEmojiRendering {
                // Emoji glyphs carry their own color, so the demo leaves the automatic renderer uncolored
                // when every automatic content value is emoji-like.  This keeps the live demo aligned with the
                // generated configuration command shown in the sheet.
                ParticleSystemView(particleSystem: system, renderer: .automatic(ParticleContent(particleContent)))
            } else {
                ParticleSystemView(particleSystem: system, renderer: .automatic(ParticleContent(particleContent), coloringStyle: demoColoringStyle))
            }
        case .text:
            ParticleSystemView(particleSystem: system, renderer: .text(ParticleContent(particleContent), coloringStyle: demoColoringStyle))
        case .symbol:
            ParticleSystemView(particleSystem: system, renderer: .symbol(ParticleContent(particleContent), coloringStyle: demoColoringStyle))
        case .shape:
            ParticleSystemView(
                particleSystem: system,
                renderer: CustomParticleRenderer { context in
                    shapeParticle(for: context)
                }
            )
        case .toggle:
            ParticleSystemView(
                particleSystem: system,
                renderer: CustomParticleRenderer { context in
                    Toggle("", isOn: $toggleParticleValue)
                        .labelsHidden()
                        // The toggle demonstrates that the particle can be a real SwiftUI control.  Tint is
                        // driven from the selected demo color so changing one toggle updates the shared state
                        // while all toggle particles keep the same visual configuration.
                        .tint(particleColor(for: context.state))
                        .frame(width: 52)
                        .particleAppearance(for: context.state)
                }
            )
        }
    }
    
    /// Coloring style used by built-in demo renderers.
    ///
    /// The `.none` segment in the UI means "use the selected solid color" for the demo rather than "inherit an
    /// unspecified foreground", which makes the ColorPicker useful for text, symbols, and automatic particles.
    private var demoColoringStyle: ParticleColoringStyle {
        return ParticleColoringStyle { state in
            particleColor(for: state)
        }
    }
    
    /// Resolves the currently selected coloring mode into a concrete color for the supplied particle state.
    private func particleColor(for state: ParticleState) -> Color {
        switch coloring {
        case .none:
            return solidColor
        case .rainbow:
            return ParticleColoringStyle.rainbow.color(for: state) ?? solidColor
        case .fire:
            return ParticleColoringStyle.fire.color(for: state) ?? solidColor
        }
    }
    
    /// Builds the custom Shape renderer used by the demo.
    ///
    /// Each shape uses the same particle appearance modifier for opacity, blur, and rotation, while fill color
    /// comes from the demo coloring controls so solid, rainbow, and fire coloring all work consistently.
    @ViewBuilder
    private func shapeParticle(for context: ParticleRenderingContext) -> some View {
        let color = particleColor(for: context.state)
        switch shapeMode {
        case .circle:
            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .particleAppearance(for: context.state)
        case .square:
            Rectangle()
                .fill(color)
                .frame(width: 40, height: 40)
                .particleAppearance(for: context.state)
        case .triangle:
            TriangleParticleShape()
                .fill(color)
                .frame(width: 46, height: 42)
                .particleAppearance(for: context.state)
        case .placard:
            Placard()
                .fill(color)
                .frame(width: 54, height: 36)
                .particleAppearance(for: context.state)
        }
    }
    
    /// Text shown by the View Configuration sheet.
    ///
    /// This keeps the generated command aligned with the current demo choices, including the renderer, so the
    /// sheet can be used as a quick copyable reference while experimenting.
    private var demoConfigurationCode: String {
        return """
ParticleSystemView(
    behavior: \(system.behavior.code),
    renderer: \(rendererCode)
)
"""
    }
    
    /// Builds a compact renderer expression for the current demo selection.
    private var rendererCode: String {
        switch rendererMode {
        case .automatic:
            if automaticContentUsesEmojiRendering {
                // Emoji renderers do not expose coloring because the glyphs are already colored.  Omitting the
                // argument here makes the sample command match the API users should actually write.
                return ".automatic(\(particleContentLiteral))"
            }
            return ".automatic(\(particleContentLiteral), \(coloringCode))"
        case .text:
            return ".text(\(particleContentLiteral), \(coloringCode))"
        case .symbol:
            return ".symbol(\(particleContentLiteral), \(coloringCode))"
        case .shape:
            return "CustomParticleRenderer { context in \(shapeMode.label) /* shape */ }"
        case .toggle:
            return "CustomParticleRenderer { context in Toggle(\"\", isOn: sharedToggleBinding) }"
        }
    }
    
    /// Escapes the renderer content as a Swift string literal for the configuration sheet.
    private var particleContentLiteral: String {
        return particleContent.debugDescription
    }
    
    /// Detects when automatic content will effectively be displayed as emoji.
    ///
    /// Automatic rendering can resolve to images, SF Symbols, or `Text`.  The demo only suppresses coloring
    /// when every comma-separated content value looks like an emoji sequence, because those glyphs already
    /// carry their own colors and should not advertise a coloring parameter.
    private var automaticContentUsesEmojiRendering: Bool {
        let values = ParticleContent(particleContent).values.filter { !$0.isEmpty }
        return !values.isEmpty && values.allSatisfy { $0.isEmojiParticleValue }
    }
    
    /// Describes the selected coloring mode in generated configuration text.
    private var coloringCode: String {
        switch coloring {
        case .none:
            return "coloringStyle: ParticleColoringStyle { _ in /* selected ColorPicker color */ }"
        case .rainbow:
            return "coloring: .rainbow"
        case .fire:
            return "coloring: .fire"
        }
    }
}

/// Demo surface that moves the emitter center around a triangle path.
///
/// This shows that particle emission can be driven by a path instead of drag input while leaving the renderer
/// choice unchanged.
private struct TrianglePathParticleSystemView<ParticleLayer: View>: View {
    @ObservedObject var particleSystem: ParticleSystem
    var background: Color
    var allowsParticleInteraction: Bool
    var particleLayer: () -> ParticleLayer
    
    init(
        particleSystem: ParticleSystem,
        background: Color,
        allowsParticleInteraction: Bool = false,
        @ViewBuilder particleLayer: @escaping () -> ParticleLayer
    ) {
        self.particleSystem = particleSystem
        self.background = background
        self.allowsParticleInteraction = allowsParticleInteraction
        self.particleLayer = particleLayer
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let center = TriangleEmitterPath.center(at: timeline.date.timeIntervalSinceReferenceDate)
            ZStack {
                background
                TriangleOutline()
                    .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                Color.clear
                    .onAppear {
                        // Seed the emitter position as soon as the path demo appears.
                        particleSystem.center = center
                    }
                    .backport.onChange(of: timeline.date) {
                        // Keep the model's normalized center moving around the triangle outline on every
                        // animation tick so newly born particles originate from the path.
                        particleSystem.center = center
                    }
                particleLayer()
                    .allowsHitTesting(allowsParticleInteraction)
                    .foregroundStyle(.white)
            }
        }
    }
}

/// Draws the visible outline used by the triangle-path emitter demo.
private struct TriangleOutline: Shape {
    func path(in rect: CGRect) -> Path {
        // The outline uses the exact same normalized vertices as the emitter path, so the dotted guide shows
        // the route newly emitted particles follow rather than a separately padded approximation.
        return TriangleEmitterPath.path(in: rect)
    }
}

/// Shared geometry for the triangle-path emitter demo.
///
/// Keeping the path math in one helper prevents the visible outline and the model's normalized emitter center
/// from drifting apart as the demo surface changes size.
private enum TriangleEmitterPath {
    /// Normalized vertices leave a comfortable margin inside the demo surface.
    static let vertices = [
        UnitPoint(x: 0.5, y: 0.12),
        UnitPoint(x: 0.12, y: 0.86),
        UnitPoint(x: 0.88, y: 0.86),
    ]
    
    /// Calculates a normalized point that moves around the edges of the triangle.
    static func center(at currentTime: TimeInterval) -> UnitPoint {
        let duration = 4.5
        let progress = currentTime.truncatingRemainder(dividingBy: duration) / duration
        let scaledProgress = progress * Double(vertices.count)
        let edgeIndex = Int(scaledProgress) % vertices.count
        let nextIndex = (edgeIndex + 1) % vertices.count
        let edgeProgress = scaledProgress - Double(edgeIndex)
        let start = vertices[edgeIndex]
        let end = vertices[nextIndex]
        return UnitPoint(
            x: start.x + (end.x - start.x) * edgeProgress,
            y: start.y + (end.y - start.y) * edgeProgress
        )
    }
    
    /// Converts the normalized emitter route into the visible shape path for the current drawing rectangle.
    static func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = vertices.first else {
            return path
        }
        path.move(to: point(for: first, in: rect))
        for vertex in vertices.dropFirst() {
            path.addLine(to: point(for: vertex, in: rect))
        }
        path.closeSubpath()
        return path
    }
    
    /// Maps a normalized unit point into concrete view coordinates.
    private static func point(for unitPoint: UnitPoint, in rect: CGRect) -> CGPoint {
        return CGPoint(
            x: rect.minX + unitPoint.x * rect.width,
            y: rect.minY + unitPoint.y * rect.height
        )
    }
}

private extension String {
    /// Returns `true` when the string looks like a complete emoji glyph or emoji sequence.
    ///
    /// The check intentionally requires an emoji-presentation signal so ordinary strings, SF Symbol names, and
    /// digit-only text are not mistaken for emoji just because Unicode marks some scalars as emoji-capable.
    var isEmojiParticleValue: Bool {
        let scalars = unicodeScalars
        guard !scalars.isEmpty else {
            return false
        }
        let hasEmojiPresentationSignal = scalars.contains { scalar in
            scalar.properties.isEmojiPresentation || scalar.value == 0xFE0F
        }
        guard hasEmojiPresentationSignal else {
            return false
        }
        return scalars.allSatisfy { scalar in
            scalar.properties.isEmoji || scalar.value == 0xFE0F || scalar.value == 0x200D
        }
    }
}

/// Filled triangle shape used as one of the custom SwiftUI particle examples.
private struct TriangleParticleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
#endif
