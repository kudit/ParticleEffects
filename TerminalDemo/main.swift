import Foundation
import ParticleEffects
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

// The terminal app composes a status line, particle frame, and bottom help rows; it does not implement a general view system.
struct TerminalSize {
	var columns: Int
	var lines: Int

	static func current() -> Self {
		var size = winsize()
		if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0, size.ws_col > 0, size.ws_row > 0 {
			return Self(columns: Int(size.ws_col), lines: Int(size.ws_row))
		}
		return Self(columns: 80, lines: 24)
	}
}

enum TerminalArrow {
	case up, down, left, right
}

enum TerminalKey {
	case character(Character)
	case arrow(TerminalArrow)
	case enter, backspace, escape
}

struct TerminalInput {
	private var bytes = [UInt8]()

	mutating func nextKey() -> TerminalKey? {
		readAvailableBytes(timeout: bytes.isEmpty ? 0 : 12)
		guard let first = bytes.first else { return nil }
		if first == 0x1B {
			if bytes.count < 3 {
				readAvailableBytes(timeout: 12)
			}
			if bytes.count >= 3, bytes[1] == 0x5B {
				let arrow: TerminalArrow?
				switch bytes[2] {
				case 0x41: arrow = .up
				case 0x42: arrow = .down
				case 0x43: arrow = .right
				case 0x44: arrow = .left
				default: arrow = nil
				}
				bytes.removeFirst(3)
				if let arrow { return .arrow(arrow) }
			}
			bytes.removeFirst()
			return .escape
		}
		if first == 0x0D || first == 0x0A {
			bytes.removeFirst()
			return .enter
		}
		if first == 0x7F || first == 0x08 {
			bytes.removeFirst()
			return .backspace
		}
		let length: Int
		switch first {
		case 0x00...0x7F: length = 1
		case 0xC2...0xDF: length = 2
		case 0xE0...0xEF: length = 3
		case 0xF0...0xF4: length = 4
		default:
			bytes.removeFirst()
			return nil
		}
		guard bytes.count >= length else { return nil }
		let value = String(bytes: bytes.prefix(length), encoding: .utf8)?.first
		bytes.removeFirst(length)
		guard let value, !value.isNewline,
			!value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { return nil }
		return .character(value)
	}

	private mutating func readAvailableBytes(timeout: Int32) {
		var descriptor = pollfd(fd: STDIN_FILENO, events: Int16(POLLIN), revents: 0)
		guard poll(&descriptor, 1, timeout) > 0, descriptor.revents & Int16(POLLIN) != 0 else { return }
		var buffer = [UInt8](repeating: 0, count: 64)
		let count = read(STDIN_FILENO, &buffer, buffer.count)
		if count > 0 { bytes.append(contentsOf: buffer.prefix(count)) }
	}
}

enum TerminalMode {
	case control, typing
}

private struct TerminalMenuItem {
	let key: String?
	let label: String
	let value: String
	let maximumWidth: Int

	var badgeWidth: Int { key == nil ? 0 : key!.count + 2 }
	var display: String {
		if label.isEmpty { return value }
		return value.isEmpty ? label : "\(label): \(value)"
	}
}

private struct TerminalMenuRow {
	let contents: String
	let visibleWidth: Int
}

struct TerminalDemo {
	private(set) var behavior = ParticleBehavior.fountain
	private(set) var coloring = Coloring.none
	private(set) var emitterPosition = Vector(x: 0.5, y: 0.5)
	private(set) var content = "😊,👍,☺️,👏,🙌"
	private(set) var mode = TerminalMode.control
	private(set) var typingBuffer = ""
	private(set) var presetIndex = 1
	private(set) var isRunning = true
	private var particles = [Particle]()
	private var particleCounter = 0
	private var lastParticleCreation: TimeInterval = .zero

	var preset: ParticleBehavior { ParticleBehavior.presets[presetIndex] }

	mutating func accept(_ key: TerminalKey, columns: Int, bodyLines: Int) {
		if case .character(let character) = key, character.lowercased() == "q", mode != .typing {
			isRunning = false
			return
		}
		if case .arrow(let arrow) = key {
			moveEmitter(arrow, columns: columns, bodyLines: bodyLines)
			return
		}
		switch mode {
		case .typing:
			acceptTyping(key)
		case .control:
			acceptMenu(key)
		}
	}

	mutating func states(at time: TimeInterval) -> [ParticleState] {
		particles.removeAll { behavior.shouldRemove(particle: $0, at: time) }
		if let particle = behavior.newParticle(
			initialPosition: emitterPosition,
			timeSinceLastGeneration: time - lastParticleCreation,
			particleCount: particleCounter
		) {
			particles.append(particle)
			particleCounter += 1
			lastParticleCreation = time
		}
		return particles.map { behavior.currentState(for: $0, at: time) }
	}

	func glyphs() -> TerminalParticleGlyphs {
		let values = ParticleContent(content).values.map { value in
			let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
			return TerminalSymbolMap.glyph(for: trimmed) ?? (trimmed.isEmpty ? " " : trimmed)
		}
		return .text(values.isEmpty ? ["✦"] : values)
	}

	var angleLabel: String {
		Self.angles.first(where: { $0.degrees == behavior.emissionAngle.rawValue })?.label ?? "custom"
	}

	var colorLabel: String {
		switch coloring {
		case .none: return "color none"
		case .rainbow: return "color rainbow"
		case .fire: return "color fire"
		}
	}

	private static let angles: [(label: String, degrees: Double)] = [
		("N", 270), ("NE", 315), ("E", 0), ("SE", 45),
		("S", 90), ("SW", 135), ("W", 180), ("NW", 225),
	]

	private mutating func acceptMenu(_ key: TerminalKey) {
		guard case .character(let character) = key else { return }
		switch character.lowercased() {
		case "p": applyPreset((presetIndex + 1) % ParticleBehavior.presets.count)
		case "t": mode = .typing; typingBuffer = ""
		case "c": coloring = Self.next(coloring, in: Coloring.allCases)
		case "b": behavior.birthRate = Self.next(behavior.birthRate, in: BirthRate.allCases)
		case "l": behavior.lifetime = Self.next(behavior.lifetime, in: Lifetime.allCases)
		case "a": cycleAngle()
		case "s": behavior.spread = Self.next(behavior.spread, in: SpreadArc.allCases)
		case "i": behavior.initialVelocity = Self.next(behavior.initialVelocity, in: InitialVelocity.allCases)
		case "g": behavior.acceleration = Self.next(behavior.acceleration, in: Array(Acceleration.allCases))
		case "r": emitterPosition = Vector(x: 0.5, y: 0.5)
		default: break
		}
	}

	private mutating func moveEmitter(_ arrow: TerminalArrow, columns: Int, bodyLines: Int) {
		let horizontalStep = 1 / Double(max(1, columns - 1))
		let verticalStep = 1 / Double(max(1, bodyLines - 1))
		switch arrow {
		case .up: emitterPosition.y -= verticalStep
		case .down: emitterPosition.y += verticalStep
		case .left: emitterPosition.x -= horizontalStep
		case .right: emitterPosition.x += horizontalStep
		}
		emitterPosition.x = min(1, max(0, emitterPosition.x))
		emitterPosition.y = min(1, max(0, emitterPosition.y))
	}

	private mutating func acceptTyping(_ key: TerminalKey) {
		switch key {
		case .enter:
			if !typingBuffer.isEmpty { content = typingBuffer }
			mode = .control
		case .escape:
			mode = .control
		case .backspace:
			if !typingBuffer.isEmpty { typingBuffer.removeLast() }
		case .character(let character):
			typingBuffer.append(character)
		default: break
		}
	}

	private mutating func cycleAngle() {
		let current = Self.angles.firstIndex(where: { $0.degrees == behavior.emissionAngle.rawValue }) ?? 0
		behavior.emissionAngle = Degrees(floatLiteral: Self.angles[(current + 1) % Self.angles.count].degrees)
	}

	private mutating func applyPreset(_ index: Int) {
		presetIndex = index
		behavior = ParticleBehavior.presets[index]
		switch behavior.label {
		case ParticleBehavior.rain.label:
			content = "drop.fill"; coloring = .none
		case ParticleBehavior.fountain.label:
			content = "😊,👍,☺️,👏,🙌"; coloring = .none
		case ParticleBehavior.bubbles.label:
			content = "circle"; coloring = .rainbow
		case ParticleBehavior.smoke.label:
			content = "circle.fill"; coloring = .none
		case ParticleBehavior.fire.label:
			content = "drop.fill"; coloring = .fire
		case ParticleBehavior.sparkle.label:
			content = "sparkle"; coloring = .rainbow
		case ParticleBehavior.sun.label:
			content = "star.fill"; coloring = .fire
		default: break
		}
	}

	private static func next<Value: Equatable>(_ current: Value, in values: [Value]) -> Value {
		guard !values.isEmpty, let index = values.firstIndex(of: current) else { return current }
		return values[(index + 1) % values.count]
	}
}

private func menuItems(for demo: TerminalDemo, columns: Int, lines: Int) -> [TerminalMenuItem] {
	let position = String(format: "(%.2f, %.2f)", demo.emitterPosition.x, demo.emitterPosition.y)
	let size = "\(columns)×\(lines)"
	if case .typing = demo.mode {
		return [
			TerminalMenuItem(key: nil, label: "", value: size, maximumWidth: 12),
			TerminalMenuItem(key: nil, label: "text", value: demo.typingBuffer.isEmpty ? "_" : demo.typingBuffer, maximumWidth: 36),
			TerminalMenuItem(key: "Enter", label: "apply", value: "", maximumWidth: 12),
			TerminalMenuItem(key: "Esc", label: "cancel", value: "", maximumWidth: 12),
			TerminalMenuItem(key: "⌫", label: "erase", value: "", maximumWidth: 10),
		]
	}
	return [
		TerminalMenuItem(key: nil, label: "", value: size, maximumWidth: 12),
		TerminalMenuItem(key: "p", label: "preset", value: demo.preset.label, maximumWidth: 22),
		TerminalMenuItem(key: "b", label: "birth", value: String(describing: demo.behavior.birthRate), maximumWidth: 22),
		TerminalMenuItem(key: "l", label: "life", value: String(describing: demo.behavior.lifetime), maximumWidth: 17),
		TerminalMenuItem(key: "a", label: "angle", value: demo.angleLabel, maximumWidth: 18),
		TerminalMenuItem(key: "s", label: "spread", value: String(describing: demo.behavior.spread), maximumWidth: 22),
		TerminalMenuItem(key: "i", label: "speed", value: String(describing: demo.behavior.initialVelocity), maximumWidth: 20),
		TerminalMenuItem(key: "g", label: "accel", value: String(describing: demo.behavior.acceleration), maximumWidth: 27),
		TerminalMenuItem(key: "c", label: "color", value: demo.colorLabel.replacingOccurrences(of: "color ", with: ""), maximumWidth: 20),
		TerminalMenuItem(key: "←↑↓→", label: "emitter", value: position, maximumWidth: 30),
		TerminalMenuItem(key: "r", label: "center", value: "", maximumWidth: 12),
		TerminalMenuItem(key: "t", label: "text", value: demo.content, maximumWidth: 38),
		TerminalMenuItem(key: "q", label: "quit", value: "", maximumWidth: 9),
	]
}

/// Places command/value fields into evenly spaced terminal columns, wrapping only when the width requires it.
private func renderMenuRows(items: [TerminalMenuItem], width: Int) -> [TerminalMenuRow] {
	let width = max(1, width)
	let gap = 2
	let columnCount = max(1, min(items.count, (width + gap) / (30 + gap)))
	let columnWidth = max(1, (width - gap * (columnCount - 1)) / columnCount)
	let packedRows = stride(from: 0, to: items.count, by: columnCount).map { start in
		Array(items[start..<min(items.count, start + columnCount)])
	}

	return packedRows.map { row in
		var rendered = ""
		var visibleWidth = 0
		for (index, item) in row.enumerated() {
			if index > 0 { rendered += String(repeating: " ", count: gap); visibleWidth += gap }
			let itemWidth = min(columnWidth, item.maximumWidth)
			let availableDisplayWidth = max(0, itemWidth - item.badgeWidth)
			let display = String(item.display.prefix(availableDisplayWidth))
			if let key = item.key {
				rendered += "\u{001B}[27m \(key) \u{001B}[7m"
			}
			rendered += display
			let actualFieldWidth = item.badgeWidth + display.count
			rendered += String(repeating: " ", count: max(0, columnWidth - actualFieldWidth))
			visibleWidth += columnWidth
		}
		return TerminalMenuRow(contents: rendered, visibleWidth: visibleWidth)
	}
}

enum TerminalSymbolMap {
	private static let symbols: [String: String] = [
		"drop.fill": "⧫", "circle": "○", "circle.fill": "●", "sparkle": "✦︎", "star.fill": "★︎",
		"star": "☆", "globe": "🌐", "flask.fill": "⚗", "heart.fill": "♥", "heart": "♡",
		"sun.max.fill": "☀", "moon.fill": "☾", "cloud.fill": "☁", "snowflake": "❄",
	]

	static func glyph(for symbolName: String) -> String? {
		return symbols[symbolName]
	}
}

func writeText(_ text: String) {
	let length = text.utf8.count
	text.withCString { pointer in
		var offset = 0
		while offset < length {
			let written = write(STDOUT_FILENO, pointer.advanced(by: offset), length - offset)
			if written > 0 {
				offset += written
			} else if written < 0 && errno == EINTR {
				continue
			} else if written < 0 && (errno == EAGAIN || errno == EWOULDBLOCK) {
				var descriptor = pollfd(fd: STDOUT_FILENO, events: Int16(POLLOUT), revents: 0)
				_ = poll(&descriptor, 1, -1)
			} else {
				break
			}
		}
	}
}

func run() {
	guard isatty(STDIN_FILENO) == 1, isatty(STDOUT_FILENO) == 1 else {
		fputs("ParticleEffectsTerminalDemo needs an interactive terminal. Run it with: swift run ParticleEffectsTerminalDemo\n", stderr)
		return
	}
	var savedTerminal = termios()
	let hasTerminal = tcgetattr(STDIN_FILENO, &savedTerminal) == 0
	if hasTerminal {
		var rawTerminal = savedTerminal
		rawTerminal.c_lflag &= ~tcflag_t(ICANON | ECHO)
		_ = tcsetattr(STDIN_FILENO, TCSANOW, &rawTerminal)
	}
	_ = signal(SIGINT, handleInterrupt)
	writeText("\u{001B}[0m\u{001B}[2J\u{001B}[H\u{001B}[?25l\u{001B}[?7l")
	defer {
		writeText("\u{001B}[0m\u{001B}[?7h\u{001B}[?25h\n")
		if hasTerminal { _ = tcsetattr(STDIN_FILENO, TCSANOW, &savedTerminal) }
	}

	var demo = TerminalDemo()
	var input = TerminalInput()
	while interrupted == 0 && demo.isRunning {
		let size = TerminalSize.current()
		let renderColumns = max(1, size.columns)
		let menuRows = renderMenuRows(items: menuItems(for: demo, columns: size.columns, lines: size.lines), width: renderColumns)
		let bodyLines = max(0, size.lines - 1 - menuRows.count)
		if let key = input.nextKey() { demo.accept(key, columns: renderColumns, bodyLines: bodyLines) }
		let states = demo.states(at: Date.timeIntervalSinceReferenceDate)
		let renderer = TerminalParticleRenderer(glyphs: demo.glyphs())
		let rows = renderer.rows(
			for: states,
			columns: renderColumns,
			lines: bodyLines,
			coloring: demo.coloring,
			emitterPosition: demo.emitterPosition
		)
		// Row one stays empty; the particle canvas begins below it and continues to the bottom menu.
		var output = "\u{001B}[1;1H\u{001B}[0m\u{001B}[K"
		for (index, row) in rows.enumerated() {
			output += "\u{001B}[0m\u{001B}[\(index + 2);1H" + row + "\u{001B}[K\u{001B}[0m"
		}
		let firstHelpLine = max(1, size.lines - menuRows.count + 1)
		for (index, menuRow) in menuRows.enumerated() {
			let padding = String(repeating: " ", count: max(0, renderColumns - menuRow.visibleWidth))
			output += "\u{001B}[0m\u{001B}[\(firstHelpLine + index);1H\u{001B}[7m" + menuRow.contents + padding + "\u{001B}[0m"
		}
		writeText(output)
		usleep(33_000)
	}
}

var interrupted: Int32 = 0

func handleInterrupt(_ signalNumber: Int32) {
	interrupted = signalNumber
}

run()
