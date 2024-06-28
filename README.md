<img src="/Development/Resources/Assets.xcassets/AppIcon.appiconset/Icon.png" height="128">

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkudit%2FParticleEffects%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kudit/ParticleEffects)

# ParticleEffects.swiftpm
ParticleEffects allows developers to create particle systems with minimal effort that are compatible with macOS, iOS, iPadOS, visionOS, tvOS, and watchOS.

The primary goals are to be easily maintainable by multiple individuals and be able to be used across all of Apple's platforms.

This is actively maintained so if there is a feature request or change, we will strive to address within a week.

## Features

- [x] SF Symbol particles
- [x] Image particles
- [x] Emoji particles
- [x] Text particles
- [x] Easily specify multiple symbols/images/emoji/text to use by comma-separating a string.
- [x] Emmitter customizations

## Requirements

- iOS 15.2+ (minimum required for Swift Playgrounds support)
- tvOS 15.0+
- watchOS 8.0+
- macOS 12.0+
- macCatalyst 14.0+
- visionOS 1.0+

## Known Issues
Built for macOS "Designed for iPad" does not return expected device results.

## Installation
Install by adding this as a package dependency to your code.  This can be done in Xcode or Swift Playgrounds!

### Swift Package Manager

#### Swift 5
```swift
dependencies: [
    .package(url: "https://github.com/kudit/ParticleEffects.git", from: "1.0.0"),
    /// ...
]
```

You can try these examples in a Swift Playground by adding package: https://github.com/kudit/ParticleEffects

## Usage
First make sure to import the framework:
```swift
import ParticleEffects
```

Here are some usage examples.

### Create a simple fire emitter.
```swift
ParticleSystemView(behavior: .fire)
    .font(.largeTitle)
    .aspectRatio(contentMode: .fit)
```

### Create a rainbow sunburst emitter.  Note the ability to take a base behavior and modify specific values.
```swift
ParticleSystemView(behavior:
    .sun.modified(
        string: "star.fill",
        birthRate: .frequent,
        blur: Blur.none,
        coloring: .rainbow
    )
).aspectRatio(contentMode: .fit)
```

### Create an emoji confetti emitter.
```swift
ParticleSystemView(behavior: .fountain, string: "😊,👍,☺️,👏,🙌")
```

All these tests can be demonstrated using the previews in the file DemoViews.swift which can be viewed in Xcode Previews or in Swift Playgrounds!

## Thanks
Inspired by [Effects Library by GetStream](https://github.com/GetStream/effects-library)

## Contributing
If you have the need for a specific feature that you want implemented or if you experienced a bug, please open an issue.

## Donations
This was a lot of work.  If you find this useful particularly if you use this in a commercial product, please consider making a donation to http://paypal.me/kudit

## Contributors
The complete list of people who contributed to this project is available [here](https://github.com/kudit/ParticleEffects/graphs/contributors).
A big thanks to everyone who has contributed! 🙏
