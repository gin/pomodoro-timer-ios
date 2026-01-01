import XCTest

final class PomodoroTimerUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    @MainActor
    func test_start_pause_reset_flow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Verify initial state
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist on launch")
        
        // 2. Start the timer
        startButton.tap()
        
        // 3. Verify button changes to "Pause"
        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.exists, "Button should change to Pause after tapping Start")
        
        // 4. Pause the timer
        pauseButton.tap()
        
        // 5. Verify button changes back to "Start"
        XCTAssertTrue(startButton.exists)
        
        // 6. Reset
        let resetButton = app.buttons["Reset"]
        resetButton.tap()
        
        // 7. Verify time text is present
        app.buttons["15min"].tap()
        XCTAssertTrue(app.staticTexts["15:00"].exists)
    }
    
    @MainActor
    func test_preset_selection() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["10min"].tap()
        XCTAssertTrue(app.staticTexts["10:00"].exists, "Timer should display 10:00 after selecting 10min preset")
        
        app.buttons["30min"].tap()
        XCTAssertTrue(app.staticTexts["30:00"].exists, "Timer should display 30:00 after selecting 30min preset")
        
        app.buttons["60min"].tap()
        XCTAssertTrue(app.staticTexts["60:00"].exists, "Timer should display 60:00 after selecting 60min preset")
        
        app.buttons["5min"].tap()
        XCTAssertTrue(app.staticTexts["05:00"].exists, "Timer should display 05:00 after selecting 5min preset")
        
        app.buttons["15min"].tap()
        XCTAssertTrue(app.staticTexts["15:00"].exists, "Timer should display 15:00 after selecting 15min preset")
    }

}
