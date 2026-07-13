<img src="/Development/Resources/Assets.xcassets/AppIcon.appiconset/Icon.png" height="128">

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkudit%2FParticleEffects%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kudit/ParticleEffects)

# ParticleEffects.swiftpm
ParticleEffects allows developers to create particle systems with minimal effort that are compatible with macOS, iOS, iPadOS, visionOS, tvOS, and watchOS.

The primary goals are to be easily maintainable by multiple individuals, employ a consistent API that can be used across all platforms, and to be maintainable using Swift Playgrounds on iPad and macOS.  APIs are typically present even on platforms that don't support all features so that availability checks do not have to be performed in external code, and where irrelevant, code can simply return optionals.

This is actively maintained so if there is a feature request or change, we will strive to address within a week.


## Features
- Can develop and modify without Xcode using Swift Playgrounds on iPad!
- Custom SwiftUI view particles
- Reusable particle renderer API
- SF Symbol particles
- Image particles
- Emoji particles
- Text particles
- Easily specify multiple symbols/images/emoji/text to use by comma-separating a string.
- Emmitter customizations


## Requirements
Most of these minimums are dictated by our usage of Date.now which is needed.
- iOS 15+ (15.2+ minimum required for Swift Playgrounds support)
- macOS 12+
- macCatalyst 13.0+ (first version available)
- tvOS 15.0+
- watchOS 8.0+
- visionOS 1.0+
- Theoretically should work with Linux, Windows, and Vapor, but haven't tested.  If you would like to help, please let us know.


## Known Issues
*See CHANGELOG.md for known issues and roadmap*


## Installation
Install by adding this as a package dependency to your code.  This can be done in Xcode or Swift Playgrounds!

### Swift Package Manager

#### Swift 5+
You can try these examples in a Swift Playground by adding package: `https://github.com/kudit/ParticleEffects`

If the repository is private, use the following link to import: `https://<your-PAT-string>@github.com/kudit/ParticleEffects.git`

Or you can manually enter the following in the Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/kudit/ParticleEffects.git", from: "2.0.2"),
]
```


## Usage
First make sure to import the framework:
```swift
import ParticleEffects
```

Here are some usage examples.

### Get the version of ParticleEffects that is imported.
```swift
let version = ParticleEffects.version
```

### Create a simple fire emitter.
```swift
ParticleSystemView(behavior: .fire, renderer: .symbol("drop.fill", coloring: .fire))
    .font(.largeTitle)
    .aspectRatio(contentMode: .fit)
```

### Create a rainbow sunburst emitter.  Note the ability to take a base behavior and modify specific values.
```swift
ParticleSystemView(
    behavior: .sun.modified(
        birthRate: .frequent,
        blur: Blur.none
    ),
    renderer: .symbol("star.fill", coloring: .rainbow)
).aspectRatio(contentMode: .fit)
```

### Create an emoji confetti emitter.
```swift
ParticleSystemView(behavior: .fountain, renderer: .emoji("😊,👍,☺️,👏,🙌"))
```

### Use a built-in renderer.
ParticleEffects 2.0 separates behavior from rendering.  Behaviors control birth rate, lifetime, velocity, acceleration, blur, and spin.  Renderers control the SwiftUI view content and any coloring model.
```swift
ParticleSystemView(
    behavior: .fountain,
    renderer: .emoji("😊,👍,☺️,👏,🙌")
)
```

You can also use built-in renderers when you want to force interpretation of renderer content.
```swift
ParticleSystemView(behavior: .sparkle, renderer: .symbol("star.fill", coloring: .rainbow))
ParticleSystemView(behavior: .rain, renderer: .text("drop.fill"))
ParticleSystemView(behavior: .bubbles, renderer: .image("BubbleAsset"))
```

### Create a custom SwiftUI particle renderer.
Custom renderers receive a `ParticleRenderingContext` with the current `ParticleState`, the owning `ParticleSystem`, the `GeometryProxy`, and the current timeline time.
```swift
struct TokenParticleRenderer: ParticleRenderer {
    let content: ParticleContent = "K,U,D,I,T"

    func particleView(for context: ParticleRenderingContext) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                )
            Text(content.value(for: context.state))
                .font(.caption.bold())
        }
        .frame(width: 44, height: 28)
        .particleAppearance(for: context.state, coloring: .rainbow)
    }
}

ParticleSystemView(
    behavior: .sparkle.modified(spin: .medium),
    renderer: TokenParticleRenderer()
)
```

### Use a one-off custom renderer closure.
For quick experiments, `CustomParticleRenderer` avoids creating a named type.
```swift
ParticleSystemView(
    behavior: .fire,
    renderer: CustomParticleRenderer { context in
        Circle()
            .fill(.orange)
            .frame(width: 12 + 24 * context.state.lifetimeAge)
            .particleAppearance(for: context.state, coloring: .fire)
    }
)
```

### Use custom coloring.
`Coloring` remains available for the simple API.  For more control, pass a `ParticleColoringStyle`.
```swift
let fadingBlue = ParticleColoringStyle { state in
    Color.blue.opacity(1 - state.lifetimeAge)
}

ParticleSystemView(
    behavior: .bubbles,
    renderer: .automatic("circle.fill", coloringStyle: fadingBlue)
)
```

### Read custom state values.
`ParticleState` includes `position`, `opacity`, `blur`, `rotation`, `lifetimeAge`, and a small `values` dictionary for behavior-specific numeric values.  Built-in fire coloring is exposed through `fireHue` and `fireSaturation` extension properties so those values do not need to be stored for every particle frame unless a custom behavior chooses to publish them.
```swift
let customGlow = context.state.value(named: "glow")
let fireHue = context.state.fireHue
let rotation = context.state.rotation
```

### SwiftPM tests
The `ParticleEffectsTests` target lives under `Development` so the package's existing Swift Playgrounds app layout remains unchanged. The manifest conditionally omits the target when Swift Playgrounds loads the package, while SwiftPM and Xcode on macOS discover it normally.

From the package directory, run:
```sh
swift test
```

In Xcode, open the package, choose **My Mac** as the destination, and run the package scheme's Test action. The tests cover deterministic model and renderer-support behavior without depending on animation timing or a running SwiftUI view hierarchy.

## Apple Framework Alternatives
Apple provides lower-level particle and animation tools such as SpriteKit emitters, Core Animation emitter layers, SwiftUI `Canvas`, and timeline-driven SwiftUI drawing.  ParticleEffects is intended for the case where you want a small SwiftUI-first package that can render normal SwiftUI views as particles while preserving simple cross-platform convenience APIs.

All these tests can be demonstrated using previews or by running the app executable that is bundled in the Development folder of the module.

## Thanks
Inspired by [Effects Library by GetStream](https://github.com/GetStream/effects-library)

## Contributing
If you have the need for a specific feature that you want implemented or if you experienced a bug, please open an issue.
If you extended the functionality yourself and want others to use it too, please submit a pull request.


## Donations
This was a lot of work.  If you find this useful particularly if you use this in a commercial product, please consider making a donation to http://paypal.me/kudit


## License
Feel free to use this in projects, however, please include a link back to this project and credit somewhere in the app.  Example Markdown and string interpolation for the version:
```swift
Text("Open Source projects used include [ParticleEffects](https://github.com/kudit/ParticleEffects) v\(ParticleEffects.version)
```


## Contributors
The complete list of people who contributed to this project is available [here](https://github.com/kudit/ParticleEffects/graphs/contributors).
A big thanks to everyone who has contributed! 🙏
