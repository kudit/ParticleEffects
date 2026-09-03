import Foundation

/// Renderer-owned values used to choose deterministic text, symbols, or emoji for particles.
///
/// This type deliberately has no SwiftUI dependency.  A particle content list is useful to any renderer,
/// including the future terminal renderer, and keeping it in the portable model prevents Linux and other
/// non-SwiftUI builds from losing model tests merely because a graphical renderer is unavailable.
public struct ParticleContent: ExpressibleByStringLiteral, Hashable, Sendable {
    /// Ordered values supplied by the renderer.
    public var values: [String]

    /// Creates content from a comma-separated string.
    ///
    /// Empty input is represented by one empty value so modulo selection remains safe and deterministic.
    public init(_ string: String) {
        let parts = string
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        self.values = parts.isEmpty ? [""] : parts
    }

    /// Creates content from a string literal for concise renderer declarations.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Returns the value selected by a particle's stable index.
    public func value(for particleState: ParticleState) -> String {
        let safeValues = values.isEmpty ? [""] : values
        // Normalize negative indexes as well as large indexes so externally supplied identities cannot produce
        // an invalid array subscript while content cycling remains deterministic on every platform.
        let index = ((particleState.particle.index % safeValues.count) + safeValues.count) % safeValues.count
        return safeValues[index]
    }
}
