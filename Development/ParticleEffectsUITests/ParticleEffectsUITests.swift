import XCTest

/// Exercises the sample application at the user-interface boundary so launch, controls, and the registered
/// module test screen are covered in addition to the package-level Swift Testing catalog.
final class ParticleEffectsUITests: XCTestCase {
    /// Launches with clean state and verifies the primary configuration controls are present and usable.
    /// Opens the configuration action where supported and verifies that the app responds to a control tap.
    @MainActor
    func testConfigurationAction() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launchEnvironment["TESTING"] = "1"
        app.launch()

        XCTAssertTrue(app.staticTexts["Content"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Coloring"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Behavior"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Control"].exists || app.staticTexts["Control"].exists)

        let configuration = app.buttons["View Configuration"]
        if configuration.waitForExistence(timeout: 5) {
            configuration.tap()
            XCTAssertTrue(app.buttons["Dismiss"].waitForExistence(timeout: 5))
            app.buttons["Dismiss"].tap()
        } else {
            // tvOS and watchOS intentionally omit this action because their compact layouts show controls inline.
            XCTAssertTrue(app.staticTexts["Content"].exists)
        }
    }
}
