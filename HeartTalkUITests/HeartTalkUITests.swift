import XCTest

final class HeartTalkUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_launch_showsRootContent() {
        let app = XCUIApplication()
        app.launch()
        // App should reach either onboarding (Splash with "Начать") or main UI ("Вопросы" tab label)
        let started = app.staticTexts["Начать"].waitForExistence(timeout: 5)
            || app.staticTexts["Вопросы"].waitForExistence(timeout: 5)
        XCTAssertTrue(started, "App did not present any root UI after launch")
    }
}
