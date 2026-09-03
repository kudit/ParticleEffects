# Changelog

## TODO: Terminal renderer and CLI example
Implement a platform-neutral particle renderer that maps ``ParticleState`` values to an ANSI terminal frame using ASCII, Unicode, or emoji glyphs. Add a command-line demonstration with an alternate-screen, full-terminal text UI, nonblocking controls, terminal-size adaptation, and deterministic renderer tests. Keep the terminal UI as a small retained-mode composition layer rather than attempting to duplicate SwiftUI's view/layout system.

## v2.0.6 2026-09-03
Backported code to decrease the minimum versions required.  UI still requires minimum iOS 15.

## v2.0.5 2026-09-01
Updated the reusable Swift Testing bridge to use Compatibility's asynchronous recursive `Module.testEntries()` API and simplified application module tracking.
Added UI Tests and additional tests.

## v2.0.4 2026-08-27
Set up SwiftPM testing with a Compatibility-style reusable test adapter and per-entry Swift Testing bridge.
Updated Compatibility.

## v2.0.3 2026-07-23
Kept the live particle display visible on compact layouts by reserving at least one third of the available height for it and moving configuration controls into an independent scroll view.
Used a bounded side-by-side configuration panel when the available width is sufficient.
Updated Compatibility to 1.18.2 and synchronized the package release surfaces.
Added a local Compatibility-style `scrollIndicators` backport candidate so the development app remains compatible with iOS 15 and can later move into Compatibility's shared backport collection.
Adjusted side-by-side configuration sizing so segmented controls remain readable, optimized emoji-only automatic rendering through the dedicated emoji renderer, and preserved the existing actor-safe timer bridge while investigating emission cadence.

## v2.0.2 2026-07-13
Added a SwiftPM test target using Compatibility's conditional manifest pattern so Swift Playgrounds continues loading only the existing app and library targets.
Added model and renderer-support regression tests plus README documentation for running them through SwiftPM and Xcode on macOS.
Added documentation for Swift Package Index score.
Updated Compatibility.

## v2.0.1 2026-06-29
Updated Compatibility.
Updated change log format.

## v2.0.0 2026-05-29
Breaking renderer refactor: moved particle display content and coloring out of `ParticleBehavior` and into reusable renderers so any SwiftUI view can be emitted from the same behavior system.  Added renderer-owned `ParticleContent`, generic `ParticleRenderer` support, `CustomParticleRenderer`, built-in automatic/text/emoji/symbol/image renderers, injectable coloring styles, rotation/spin state, and named state values for future custom scalar data.  Updated the development app with grouped content/coloring/behavior configuration, Compatibility `Placard` shape particles, shared-state Toggle particles, and a triangle path emitter demo.  Fixed the macOS App Icon asset catalog by providing all required macOS icon slots.  Fixed drag/hold animation stalls by filtering expired particles during render and keeping the particle update timer active in common run-loop modes.  Refined the demo controls so emitter control mode, full content presets, renderer options, solid color picking, and behavior tuning are separate sections.  Added deprecated 1.x convenience initializers and renderer shims so legacy `string:` call sites keep compiling while warning callers to move content into the renderer.
Fixed the triangle path demo guide so the dotted outline is drawn from the same normalized route followed by the emitter, and updated the configuration preview so automatic emoji content omits coloring parameters.

## v1.1.7 2026-05-11
Fixed some Xcode warnings using Codex.  Package and ParticleEffects versions were not updated in 1.1.6.  Updated year to not be hard-coded.

## v1.1.6 2026-04-14
Updated Compatibility to address issues with WASM (not that this really matters since this is primarily a UI package but maybe this will be used to do particle systems in ASCII?)

## v1.1.5 2025-06-11
Standardized Package.swift, CHANGELOG.md, README.md, and LICENSE.txt files.  Standardized deployment targets.  Added PlaygroundAssets for silencing asset warnings in Swift Playgrounds.  Updated Compatibility for support for WASM and Android.  Works in Swift Playgrounds 4.6.

## v1.1.4 2024-07-17
Restructured Xcode project for consistency and clarity.  Changed dependency from swift-collections to Compatibility to remove redundant code.  Updated icon to reflect new themeing.  Reduced minimum iOS version (slighlty).  Perhaps in the future we can create a backport Date.now for older OS versions if necessary.  Updated License guidance to match Compatibility. *PASSES SWIFTPACKAGEINDEX TESTS*

## v1.1.3 2024-06-29
Added note about location of example code.  Fixed a couple additional places where we had static vars instead of lets.  Fixed wrong version in ParticleEffects.swift.  Fixed on iPhone in light mode.

## v1.1.2 2024-06-26
Fixed README.md examples to use new syntax.  Added compatibility init in case someone uses old syntax.  Switched Analyze to use Release target which found an issue for watchOS testing which was fixed by adding LSApplicationCategory.

## v1.1.1 2024-06-25
Don't want to use Canvas because 1) can't draw outside canvas (which is what we need) and 2) more difficult to draw any SwiftUI view and make those views interactable if necessary.  So instead have calculate position so we don't actually update the particle itself, we just re-calculate the values (which may be more expensive but then we're only calculating when we render rather than more frequently).  But still need to calculate and add particles to the system periodically... do that with a timer but render particles without updating model.  Should also be used for birthing and removing particles.

## v1.1.0 2024-06-25
Converted several static variables from `var` to `let` for clarity and concurrency safety.  Removed several unnecessary generic abstractions and custom conifgurations since really this isn't needed yet and it added unnecessary complication.  Reworked Behaviors into double representable values so end users can fully customize by providing a value rather than locked to enum values, however, maintains cases that can be iterated over for compatibility and simplicity.  Will be re-working into canvas but this is working and available for reference (but not free from warnings).  https://developer.apple.com/wwdc21/10021?time=868

## v1.0.9 2024-06-19
Fixed data race errors when using strict concurrency checking.

## v1.0.8 2024-06-03
Improved documentation for case parameters.  Added simplified example code for animated particle along a line.  Restored Swift version to 5.7 using checks for #Preview and @Published values.

## v1.0.7 2024-05-29
Fixed project so only one version check is needed not per target.  Set Swift version minimum to 5.9 since that's needed for #Preview {} functionality.

## v1.0.6 2024-05-25
Added checks for SwiftUI to add support for Linux.

## v1.0.5 2024-05-25
Fixed so that SwiftPackageIndex.com tests work on all platforms (thank you @finestructure!).

## v1.0.4 2024-05-15
Attempted to re-work Package.swift for more platform compatibility with swiftpackageindex.com.

## v1.0.3 2024-05-13
Added SimpleDemoView.  Reanmed Scheme in Xcode project.  Extracted ParticleEffects.swift to make it easier to find for version updates.  Re-worked Package.swift to be cleaner and support `swift package dump-package` for swiftpackageindex.com and enhanced for code re-use.

## v1.0.2 2024-05-07
 Fixed spacing in ChangeLog.  Updated icon to prevent confusion with KuditFrameworks.  Renamed from MotionEffects to ParticleEffects.

## v1.0.1 2024-05-04
Changed version to MotionEffects.version for clarity/simplicity.  Added convenience initializer for ParticleSystemView.

## v1.0.0 2024-05-03
Initial code and features.


## Bugs to fix:
Known issues that need to be addressed.
- [ ] Investigate and fix when pressing a button or holding down the mouse button on the (x) button or scrolling, it stops the animation... Is it because the animation and particle system are MainActor isolated?  Should we create an actor for the particle system that can continue to run independent of the MainActor so UI updates are only done then?

## Roadmap:
Planned features and anticipated API changes.  If you want to contribute, this is a great place to start.
- [ ] Add actual gravity option to link to device gravity for fun.
// have particle acceleration use current position and some value of delta in time since last so that particles can change behavior and visibility without changing position.

## Proposals:
This is where proposals can be discussed for potential movement to the roadmap.
- [ ] Create additional emitters like fire and smoke using blurred SF symbols so we don't need resources?
- [ ] Add paged tabbed view for configuration and various demos like SimpleDemoView and include a demo for moving particles along a Shape path.

## Legacy Reference
NOTE: Version needs to be updated in the following places:
- [ ] Xcode project version (in build settings - normal and watch targets should inherit)
- [ ] Package.swift iOSApplication product displayVersion.
- [ ] ParticleEffects.version constant (must be hard coded since inaccessible in code)
- [ ] Update changelog and tag with matching version in GitHub.
