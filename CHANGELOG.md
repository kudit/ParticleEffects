# ChangeLog

NOTE: Version needs to be updated in the following places:
- [ ] Xcode project version (in build settings - normal and watch targets should inherit)
- [ ] Package.swift iOSApplication product displayVersion.
- [ ] ParticleEffects.version constant (must be hard coded since inaccessible in code)
- [ ] Tag with matching version in GitHub.

v1.1.4 7/17/2024 Restructured Xcode project for consistency and clarity.  Changed dependency from swift-collections to Compatibility to remove redundant code.  Updated icon to reflect new themeing.  Reduced minimum iOS version (slighlty).  Perhaps in the future we can create a backport Date.now for older OS versions if necessary.  Updated License guidance to match Compatibility.

v1.1.3 6/29/2024 Added note about location of example code.  Fixed a couple additional places where we had static vars instead of lets.  Fixed wrong version in ParticleEffects.swift.  Fixed on iPhone in light mode.

v1.1.2 6/26/2024 Fixed README.md examples to use new syntax.  Added compatibility init in case someone uses old syntax.  Switched Analyze to use Release target which found an issue for watchOS testing which was fixed by adding LSApplicationCategory.

v1.1.1 6/25/2024 Don't want to use Canvas because 1) can't draw outside canvas (which is what we need) and 2) more difficult to draw any SwiftUI view and make those views interactable if necessary.  So instead have calculate position so we don't actually update the particle itself, we just re-calculate the values (which may be more expensive but then we're only calculating when we render rather than more frequently).  But still need to calculate and add particles to the system periodically... do that with a timer but render particles without updating model.  Should also be used for birthing and removing particles.

v1.1.0 6/25/2024 Converted several static variables from `var` to `let` for clarity and concurrency safety.  Removed several unnecessary generic abstractions and custom conifgurations since really this isn't needed yet and it added unnecessary complication.  Reworked Behaviors into double representable values so end users can fully customize by providing a value rather than locked to enum values, however, maintains cases that can be iterated over for compatibility and simplicity.  Will be re-working into canvas but this is working and available for reference (but not free from warnings).  https://developer.apple.com/wwdc21/10021?time=868

v1.0.9 6/19/2024 Fixed data race errors when using strict concurrency checking.

v1.0.8 6/3/2024 Improved documentation for case parameters.  Added simplified example code for animated particle along a line.  Restored Swift version to 5.7 using checks for #Preview and @Published values.

v1.0.7 5/29/2024 Fixed project so only one version check is needed not per target.  Set Swift version minimum to 5.9 since that's needed for #Preview {} functionality.

v1.0.6 5/25/2024 Added checks for SwiftUI to add support for Linux.

v1.0.5 5/25/2024 Fixed so that SwiftPackageIndex.com tests work on all platforms (thank you @finestructure!).

v1.0.4 5/15/2024 Attempted to re-work Package.swift for more platform compatibility with swiftpackageindex.com.

v1.0.3 5/13/2024 Added SimpleDemoView.  Reanmed Scheme in Xcode project.  Extracted ParticleEffects.swift to make it easier to find for version updates.  Re-worked Package.swift to be cleaner and support `swift package dump-package` for swiftpackageindex.com and enhanced for code re-use.

v1.0.2 5/7/2024  Fixed spacing in ChangeLog.  Updated icon to prevent confusion with KuditFrameworks.  Renamed from MotionEffects to ParticleEffects.

v1.0.1 5/4/2024 Changed version to MotionEffects.version for clarity/simplicity.  Added convenience initializer for ParticleSystemView.

v1.0.0 5/3/2024 Initial code and features.


## Bugs to fix:
Known issues that need to be addressed.

- [ ] Investigate and fix when pressing a button or holding down the mouse button on the (x) button or scrolling, it stops the animation... Is it because the animation and particle system are MainActor isolated?  Should we create an actor for the particle system that can continue to run independent of the MainActor so UI updates are only done then?
- [ ] None known! 😊 


## Roadmap:
Planned features and anticipated API changes.  If you want to contribute, this is a great place to start.

- [ ] Add actual gravity option to link to device gravity for fun.
// have particle acceleration use current position and some value of delta in time since last so that particles can change behavior and visibility without changing position.

## Proposals:
This is where proposals can be discussed for potential movement to the roadmap.

- [ ] Create additional emitters like fire and smoke using blurred SF symbols so we don't need resources?
- [ ] Add paged tabbed view for configuration and various demos like SimpleDemoView and include a demo for moving particles along a Shape path.
