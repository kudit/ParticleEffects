//
//  AdaptablePicker.swift
//  ParticleEffects
//
//  Created by Ben Ku on 10/28/26.
//

#if canImport(SwiftUI)
import SwiftUI
import Compatibility // TODO: Move this to Compatibility

/// Wraps a standard SwiftUI picker and selects a segmented, menu, or automatic presentation by fit.
///
/// `PickerStyle` only exposes underscored rendering requirements for custom conformances, so this local
/// view owns its style selection and lets `ViewThatFits` compare the standard pickers' intrinsic sizes. SwiftUI
/// doesn't expose a public environment value for reading a `.pickerStyle` modifier applied to this wrapper.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public struct AdaptablePicker<SelectionValue: Hashable, PickerContent: View>: View {
	public let title: String
    public let selection: Binding<SelectionValue>
    public let content: () -> PickerContent

    public init(
		_ title: String,
		selection: Binding<SelectionValue>,
		@ViewBuilder content: @escaping () -> PickerContent
	) {
		self.title = title
		self.selection = selection
		self.content = content
	}

    private var fallback: some View {
        Picker(title, selection: selection, content: content)
            .pickerStyle(.automatic)
    }

    public var body: some View {
#if os(watchOS)
		fallback
#else
		if #available(iOS 16, macOS 13, tvOS 17, *) {
			AnyView(fittingPicker)
        } else if #available(iOS 14, macOS 11, tvOS 17, *) {
            AnyView(menuPicker)
		} else {
			fallback
		}
#endif
	}

#if !os(watchOS)
	/// Keeps the newer fit-based presentation out of the legacy deployment path.
	@available(iOS 16, macOS 13, tvOS 17, *)
	private var fittingPicker: some View {
		ViewThatFits(in: .horizontal) {
			picker(style: .segmentedBackport)
				.fixedSize(horizontal: true, vertical: false)

			HStack(spacing: 12) {
				Text(title)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
				Spacer(minLength: 8)
				picker(style: .menu)
					.labelsHidden()
					.accessibilityLabel(title)
			}
			.frame(maxWidth: .infinity)

			picker(style: .automatic)
				.frame(maxWidth: .infinity, alignment: .trailing)
		}
	}

	/// Uses a justified menu where ViewThatFits is unavailable on the deployment target.
	@available(iOS 14, macOS 11, tvOS 17, *)
	private var menuPicker: some View {
		HStack(spacing: 12) {
			Text(title)
				.lineLimit(1)
				.fixedSize(horizontal: true, vertical: false)
			Spacer(minLength: 8)
			picker(style: .menu)
				.labelsHidden()
				.accessibilityLabel(title)
		}
		.frame(maxWidth: .infinity)
	}
#endif

	private func picker<Style: PickerStyle>(style: Style) -> some View {
		Picker(title, selection: selection, content: content)
			.pickerStyle(style)
	}
}

#endif
