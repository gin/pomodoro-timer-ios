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
        
        // 1. Verify initial state (Should see "Start" button)
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
        
        // 7. Verify time text is present (e.g. checking for a valid time format like "25:00" or whatever preset was last)
        // Since persistence is on, we can't guarantee "25:00" without clearing data, 
        // but we can verify the text element exists.
        // Let's tap 25min to be sure if we want exact matching.
        app.buttons["25min"].tap()
        XCTAssertTrue(app.staticTexts["25:00"].exists)
    }
    
    @MainActor
    func test_preset_selection() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Tap 15min preset
        app.buttons["15min"].tap()
        
        // 2. Verify display updates to 15:00
        XCTAssertTrue(app.staticTexts["15:00"].exists, "Timer should display 15:00 after selecting 15min preset")
        
        // 3. Tap 20min preset
        app.buttons["20min"].tap()
        
        // 4. Verify display updates to 20:00
        XCTAssertTrue(app.staticTexts["20:00"].exists, "Timer should display 20:00 after selecting 20min preset")
        
        // 5. Tap 25min preset
        app.buttons["25min"].tap()
        
        // 6. Verify display updates to 25:00
        XCTAssertTrue(app.staticTexts["25:00"].exists, "Timer should display 25:00 after selecting 25min preset")
        
        // 7. Tap 30min preset
        app.buttons["30min"].tap()
        
        // 8. Verify display updates to 30:00
        XCTAssertTrue(app.staticTexts["30:00"].exists, "Timer should display 30:00 after selecting 30min preset")
    }
}
