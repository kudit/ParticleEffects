#if canImport(XCTest)
import XCTest

/// Exercises the sample application at the user-interface boundary so launch, controls, and the registered
/// module test screen are covered in addition to the package-level Swift Testing catalog.
final class ParticleEffectsUITests: XCTestCase {
    /// Launches with clean state and verifies the primary configuration controls are present and usable.
    /// Opens the configuration action where supported and verifies that the app responds to a control tap.
    @MainActor
    func testConfigurationAction() async throws {
        let app = XCUIApplication()
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launchEnvironment["TESTING"] = "1"
        app.launch()

        let contentVisible = await waitForElement(app.staticTexts["Content"], timeout: 10)
        XCTAssertTrue(contentVisible)
        let coloringVisible = await waitForElement(app.staticTexts["Coloring"], timeout: 10)
        XCTAssertTrue(coloringVisible)
        let behaviorVisible = await waitForElement(app.staticTexts["Behavior"], timeout: 10)
        XCTAssertTrue(behaviorVisible)
        XCTAssertTrue(app.buttons["Control"].exists || app.staticTexts["Control"].exists)

        let configuration = app.buttons["View Configuration"]
        if await waitForElement(configuration, timeout: 5) {
            configuration.tap()
            let dismissVisible = await waitForElement(app.buttons["Dismiss"], timeout: 5)
            XCTAssertTrue(dismissVisible)
            app.buttons["Dismiss"].tap()
        } else {
            // tvOS and watchOS intentionally omit this action because their compact layouts show controls inline.
            XCTAssertTrue(app.staticTexts["Content"].exists)
        }
    }

    /// Polls asynchronously rather than blocking the main actor on XCTest's timeout-based wait API.
    @MainActor
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists { return true }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        return element.exists
    }
}
#endif
