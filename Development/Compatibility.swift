// This has been a godsend! https://davedelong.com/blog/2021/10/09/simplifying-backwards-compatibility-in-swift/

import SwiftUI

public struct Backport<Content> {
    public let content: Content

    public init(_ content: Content) {
        self.content = content
    }
}

public extension View {
    var backport: Backport<Self> { Backport(self) }
}

#if os(watchOS)
public extension PickerStyle where Self == DefaultPickerStyle {
    // can't just name segmented because marked as explicitly unavailable
    static var segmentedBackport: DefaultPickerStyle {
        return .automatic
    }
}
#else
public extension PickerStyle where Self == SegmentedPickerStyle {
    // can't just name segmented because marked as explicitly unavailable
    static var segmentedBackport: SegmentedPickerStyle {
        return .segmented
    }
}
#endif

@available(watchOS 8.0, tvOS 15.0, macOS 12.0, *)
public extension Backport where Content: View {
    func onChange<V>(
        of value: V,
        perform action: @escaping () -> Void
    ) -> some View where V : Equatable {
        Group {
            if #available(iOS 17.0, macOS 14.0, macCatalyst 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
                content.onChange(of: value) {
                    action()
                }
            } else {
                content.onChange(of: value) { _ in
                    action()
                }
            }
        }
    }
    func backgroundStyle(_ style: some ShapeStyle) -> some View {
        Group {
            if #available(watchOS 9.0, tvOS 16.0, macOS 13.0, iOS 16.0, *) {
                content.backgroundStyle(style)
            } else {
                // Fallback on earlier versions
                if let color = style as? Color {
                    content.background(color)
                } else {
                    content // don't apply style if watchOS 6 or 7
                }
            }
        }
    }
}

public protocol ContainerView: View {
    associatedtype Content
    init(content: @escaping () -> Content)
}
public extension ContainerView {
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(content: content)
    }
}

@available(watchOS 8.0, tvOS 15.0, macOS 12.0, *)
public struct BackportNavigationStack<Content: View>: ContainerView {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        if #available(macCatalyst 16.0, iOS 16, watchOS 9.0, macOS 13.0, tvOS 16.0, *) {
            NavigationStack(root: content)
        } else {
            // Fallback on earlier versions
            NavigationView(content: content)
        }
    }
}
