# ChangeLog

NOTE: Version needs to be updated in the following places:
- [ ] Xcode project version (normal target)
- [ ] Xcode project version (watch target)
- [ ] Package.swift iOSApplication product displayVersion.
- [ ] ParticleEffects.version constant (must be hard coded since inaccessible in code)
- [ ] Tag with matching version in GitHub.

v1.0.6 5/25/2024 Added checks for SwiftUI to add support for Linux.

v1.0.5 5/25/2024 Fixed so that SwiftPackageIndex.com tests work on all platforms (thank you @finestructure!).

v1.0.4 5/15/2024 Attempted to re-work Package.swift for more platform compatibility with swiftpackageindex.com.

v1.0.3 5/13/2024 Added SimpleDemoView.  Reanmed Scheme in Xcode project.  Extracted ParticleEffects.swift to make it easier to find for version updates.  Re-worked Package.swift to be cleaner and support `swift package dump-package` for swiftpackageindex.com and enhanced for code re-use.

v1.0.2 5/7/2024  Fixed spacing in ChangeLog.  Updated icon to prevent confusion with KuditFrameworks.  Renamed from MotionEffects to ParticleEffects.

v1.0.1 5/4/2024 Changed version to MotionEffects.version for clarity/simplicity.  Added convenience initializer for ParticleSystemView.

v1.0.0 5/3/2024 Initial code and features.


## Bugs to fix:
Known issues that need to be addressed.

- [ ] None known! 😊 

## Roadmap:
Planned features and anticipated API changes.  If you want to contribute, this is a great place to start.

- [ ] Add actual gravity option to link to device gravity for fun.

## Proposals:
This is where proposals can be discussed for potential movement to the roadmap.

- [ ] Create additional emitters like fire and smoke using blurred SF symbols so we don't need resources?
- [ ] Optimize so that entire view isn't included with particles and just values to keep things light.
- [ ] Add paged tabbed view for configuration and various demos like SimpleDemoView and include a demo for moving particles along a Shape path.
