//
//  PomodoroTimerTests.swift
//  PomodoroTimerTests
//
//  Created by luigi on 12/28/25.
//

import XCTest
@testable import PomodoroTimer

final class PomodoroTimerTests: XCTestCase {
    //    override func setUpWithError() throws {
    //        // Put setup code here. This method is called before the invocation of each test method in the class.
    //    }
    //
    //    override func tearDownWithError() throws {
    //        // Put teardown code here. This method is called after the invocation of each test method in the class.
    //    }
    //
    //    func testExample() throws {
    //        // This is an example of a functional test case.
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //        // Any test you write for XCTest can be annotated as throws and async.
    //        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    //        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    //    }
    //
    //    func testPerformanceExample() throws {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
    @MainActor
    func test_start_sets_initial_state() {
        var engine = PomodoroEngine()
        engine.start(work: 1500)
        XCTAssertEqual(engine.phase, .work)
        XCTAssertEqual(engine.remaining, 1500)
    }
    
    func test_tick_counts_down() {
        var engine = PomodoroEngine()
        engine.start(work: 3)
        engine.tick()
        XCTAssertEqual(engine.remaining, 2)
    }
    
    @MainActor
    func test_transition_to_rest() {
        var engine = PomodoroEngine()
        engine.start(work: 1)
        engine.tick() // 0 remaining, phase transitions to rest
        XCTAssertEqual(engine.phase, .rest)
        
        // Manual startRest usage
        engine.startRest(5)
        XCTAssertEqual(engine.phase, .rest)
        XCTAssertEqual(engine.remaining, 5)
    }
    
    @MainActor
    func test_stop_resets_all_state() {
        var engine = PomodoroEngine()
        engine.start(work: 10)
        engine.stop()
        XCTAssertEqual(engine.phase, .stopped)
        XCTAssertEqual(engine.remaining, 0)
    }
    
    @MainActor
    func test_model_progress_calculation() {
        let model = PomodoroModel()
        model.setPreset(minutes: 100) // 6000 seconds
        model.start()
        
        // Initial progress 0
        XCTAssertEqual(model.progress, 0.0)
        
        func tearDown() {
            // Ensure UserDefaults is clean for the next test
            let keys = ["workDurationMinutes", "restDurationMinutes"]
            for key in keys {
                UserDefaults.standard.removeObject(forKey: key)
            }
            super.tearDown()
        }
        
        @MainActor
        func test_model_progress_calculation() {
            let model = PomodoroModel()
            model.setPreset(minutes: 100) // 6000 seconds
            model.start()
            
            // Initial progress 0
            XCTAssertEqual(model.progress, 0.0)
            
            // Cleanup: Important to stop the timer so it doesn't leak into other tests
            model.pause()
        }
        
        @MainActor
        func test_persistence_saves_settings() {
            let key = "workDurationMinutes"
            let model = PomodoroModel()
            
            // Initial default
            XCTAssertEqual(model.selectedMinutes, 25.0)
            
            // Change preset (Work phase)
            model.setPreset(minutes: 45)
            XCTAssertEqual(UserDefaults.standard.double(forKey: key), 45.0)
            
            // New model instance should load it
            let newModel = PomodoroModel()
            XCTAssertEqual(newModel.selectedMinutes, 45.0)
        }
        
        @MainActor
        func test_reset_restores_work_preset() {
            // Mock saved work duration
            UserDefaults.standard.set(30.0, forKey: "workDurationMinutes")
            
            let model = PomodoroModel()
            // Ensure it loaded the 30m
            XCTAssertEqual(model.selectedMinutes, 30.0)
            
            // Change to 15m
            model.setPreset(minutes: 15.0)
            XCTAssertEqual(model.selectedMinutes, 15.0)
            
            // Reset
            model.reset()
            
            // Reset should stop timer and reload work duration (which is now 15m)
            XCTAssertEqual(model.selectedMinutes, 15.0)
            XCTAssertFalse(model.isRunning)
        }
    }
}
