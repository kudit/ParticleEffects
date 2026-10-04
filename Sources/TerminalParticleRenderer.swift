import Foundation

/// Glyph family used by ``TerminalParticleRenderer``.
public enum TerminalParticleGlyphs: Sendable {
	/// Compact glyphs supported by plain ASCII terminals.
	case ascii
	/// Single-column Unicode shapes for terminals with Unicode support.
	case unicode
	/// Emoji content, selected deterministically by particle index.
	case emoji([String])
	/// Text values cycled by stable particle index, including words and named-symbol fallbacks.
	case text([String])
}

/// Maps normalized ``ParticleState`` positions to a deterministic ANSI terminal frame.
///
/// Coordinates use the same normalized space as ``Vector/cgPoint(_:)``: `(0, 0)` is the top-left and
/// `(1, 1)` is the bottom-right. Each axis scales independently across the available terminal columns and
/// rows, equivalent to mapping a 50×20 logical world onto the current canvas. Particles outside that rectangle are clipped.
public struct TerminalParticleRenderer: Sendable {
	public var glyphs: TerminalParticleGlyphs
	public var background: Character

	/// Creates a renderer with a selected glyph family and terminal cell correction.
	public init(glyphs: TerminalParticleGlyphs = .unicode, background: Character = " ") {
		self.glyphs = glyphs
		self.background = background
	}

	/// Renders particle states into rows without cursor or screen-control sequences.
	public func rows(
		for states: [ParticleState],
		columns: Int,
		lines: Int,
		coloring: Coloring = .none,
		emitterPosition: Vector? = nil
	) -> [String] {
		guard columns > 0, lines > 0 else { return [] }
		var cells = Array(repeating: Array(repeating: TerminalCell(glyph: String(background), color: nil), count: columns), count: lines)
		for state in states {
			let x = state.position.x
			let y = state.position.y
			guard x.isFinite, y.isFinite, x >= 0, x <= 1, y >= 0, y <= 1 else { continue }
			let column = min(columns - 1, Int((x * Double(max(0, columns - 1))).rounded()))
			let line = min(lines - 1, Int((y * Double(max(0, lines - 1))).rounded()))
			let color = ansiForegroundCode(for: state, coloring: coloring)
			let glyph = glyph(for: state)
			// Keep one grapheme per terminal cell. This keeps placement deterministic; wide emoji
			// still depend on the terminal's own glyph width, so use narrow symbols when possible.
			cells[line][column] = TerminalCell(glyph: glyph, color: color)
		}
		if let emitterPosition,
			emitterPosition.x.isFinite, emitterPosition.y.isFinite,
			emitterPosition.x >= 0, emitterPosition.x <= 1,
			emitterPosition.y >= 0, emitterPosition.y <= 1 {
			let column = min(columns - 1, Int((emitterPosition.x * Double(max(0, columns - 1))).rounded()))
			let line = min(lines - 1, Int((emitterPosition.y * Double(max(0, lines - 1))).rounded()))
			cells[line][column] = TerminalCell(glyph: "@", color: nil)
		}
		return cells.map { row in
			row.map { cell in
				guard let color = cell.color else { return cell.glyph }
				// Use standard ANSI foreground palette codes rather than truecolor extensions. Reset
				// before and after each glyph so reverse-video or background styling cannot leak in.
				return "\u{001B}[0m\u{001B}[\(color)m\(cell.glyph)\u{001B}[0m"
			}.joined() + "\u{001B}[0m"
		}
	}

	/// Returns a complete frame with a home-cursor ANSI sequence and newline-separated rows.
	public func frame(
		for states: [ParticleState],
		columns: Int,
		lines: Int,
		coloring: Coloring = .none,
		emitterPosition: Vector? = nil
	) -> String {
		return "\u{001B}[H" + rows(for: states, columns: columns, lines: lines, coloring: coloring, emitterPosition: emitterPosition).joined(separator: "\n")
	}

	private struct TerminalCell {
		let glyph: String
	let color: Int?
	}

	private func glyph(for state: ParticleState) -> String {
		switch glyphs {
		case .ascii:
			return String(state.opacity < 0.35 ? "." : state.opacity < 0.7 ? "+" : "*")
		case .unicode:
			return String(state.opacity < 0.35 ? "·" : state.opacity < 0.7 ? "✦" : "✹")
		case .emoji(let choices), .text(let choices):
			guard !choices.isEmpty else { return "*" }
			let index = ((state.particle.index % choices.count) + choices.count) % choices.count
			return choices[index].isEmpty ? "*" : choices[index]
		}
	}

	/// Maps renderer colors into portable ANSI foreground palette entries.
	private func ansiForegroundCode(for state: ParticleState, coloring: Coloring) -> Int? {
		switch coloring {
		case .none:
			return nil
		case .rainbow:
			// Cycle through visible standard ANSI foreground colors. Avoid black so particles remain
			// visible on the common dark terminal background.
			let palette = [31, 33, 32, 36, 34, 35, 91, 93, 92, 96, 94, 95]
			let index = ((state.particle.index % palette.count) + palette.count) % palette.count
			return palette[index]
		case .fire:
			// The shared fire hue moves from yellow toward red as particles age. Quantize that
			// progression into standard ANSI red, bright red, yellow, and bright yellow.
			if state.fireHue >= 0.14 { return state.fireSaturation < 0.5 ? 33 : 93 }
			if state.fireHue >= 0.08 { return 33 }
			if state.fireHue >= 0.025 { return 91 }
			return 31
		}
	}
}
