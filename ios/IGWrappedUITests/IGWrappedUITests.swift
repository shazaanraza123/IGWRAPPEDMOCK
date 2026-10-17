import XCTest

final class IGWrappedUITests: XCTestCase {
    func testLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.state, .runningForeground)
    }
}
