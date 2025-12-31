import Testing
import Foundation
@testable import PomodoroTimer

struct TestingTests {
    let engine = PomodoroEngine()
    
    @Test func test_sanity() {
        #expect(1 == 1)
    }
    
    @Test()
    func test_what() async throws {
        #expect(1 == 1)
    }
    @Test("test What is this")
    func test_what1() async throws {
        #expect(1 == 1)
    }
    
    @Test("Test with various values", arguments: [
        1, 2, 3,
    ])
    func what2(n: Int) async throws {
        try #require(n > 0)
        #expect(n == n)
    }
}

struct PomodoroEngineTests {
    @Test func test_initial_state() {
        var engine = PomodoroEngine()
        #expect(engine.phase == .stopped)
        #expect(engine.remaining == 0)
        #expect(engine.total == 0)
    }

    @Test func test_start_work() {
        var engine = PomodoroEngine()
        engine.start(work: 1500)
        #expect(engine.phase == .work)
        #expect(engine.total == 1500)
        #expect(engine.remaining == 1500)
    }

    @Test func test_tick_decrements_remaining() {
        var engine = PomodoroEngine()
        engine.start(work: 10)
        engine.tick()
        #expect(engine.remaining == 9)
        #expect(engine.total == 10)
    }

    @Test func test_transition_work_to_rest() {
        var engine = PomodoroEngine()
        engine.start(work: 1)
        engine.tick()
        #expect(engine.phase == .rest)
        #expect(engine.remaining == 0)
        #expect(engine.total == 1)
    }

    @Test func test_start_rest() {
        var engine = PomodoroEngine()
        engine.startRest(300)
        #expect(engine.phase == .rest)
        #expect(engine.total == 300)
        #expect(engine.remaining == 300)
    }

    @Test func test_transition_rest_to_stopped() {
        var engine = PomodoroEngine()
        engine.startRest(1)
        engine.tick()
        #expect(engine.phase == .stopped)
        #expect(engine.remaining == 0)
        #expect(engine.total == 1)
    }

    @Test func test_stop_resets_state() {
        var engine = PomodoroEngine()
        engine.start(work: 10)
        engine.tick()
        engine.stop()
        #expect(engine.phase == .stopped)
        #expect(engine.remaining == 0)
        #expect(engine.total == 0)
    }

    @Test func test_tick_at_zero_does_nothing() {
        var engine = PomodoroEngine()
        #expect(engine.remaining == 0)
        engine.tick()
        #expect(engine.remaining == 0)
        #expect(engine.phase == .stopped)
    }

    @MainActor
    @Test("Phase transition cycle", arguments: [
        (PomodoroPhase.work, 1),
        (PomodoroPhase.rest, 1)
    ])
    func test_transitions(phase: PomodoroPhase, duration: Int) {
        var engine = PomodoroEngine()
        if phase == .work {
            engine.start(work: duration)
        } else {
            engine.startRest(duration)
        }
        
        engine.tick()
        
        if phase == .work {
            #expect(engine.phase == .rest)
        } else {
            #expect(engine.phase == .stopped)
        }
    }
}

@MainActor
struct PomodoroModelTests {
    // Helper to clean up UserDefaults before each test
    private func cleanUserDefaults() {
        // Remove the app's persistent domain to isolate tests
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        let keys = ["workDurationMinutes", "restDurationMinutes"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    @Test func test_initial_values() {
        cleanUserDefaults()
        let model = PomodoroModel()
        #expect(model.selectedMinutes == 25.0)
        #expect(model.phase == .stopped)
        #expect(model.isRunning == false)
    }

    @Test func test_progress_calculation() {
        cleanUserDefaults()
        let model = PomodoroModel()
        model.setPreset(minutes: 10) // 600 seconds
        
        // At start (0/600 processed)
        #expect(model.progress == 0.0)
    }

    @Test func test_persistence_saves_work_duration() {
        cleanUserDefaults()
        let model = PomodoroModel()
        model.setPreset(minutes: 45)
        
        #expect(UserDefaults.standard.double(forKey: "workDurationMinutes") == 45.0)
        
        let newModel = PomodoroModel()
        #expect(newModel.selectedMinutes == 45.0)
    }

    @Test(.disabled("Needs mock to test in rest state, or test in UI test"))
    func test_persistence_saves_rest_duration() {}

    @Test func test_reset_stops_and_restores_preset() {
        cleanUserDefaults()
        UserDefaults.standard.set(30.0, forKey: "workDurationMinutes")
        
        let model = PomodoroModel()
        model.start()
        #expect(model.isRunning == true)
        
        model.reset()
        #expect(model.isRunning == false)
        #expect(model.phase == .stopped)
        #expect(model.selectedMinutes == 30.0)
    }

    @Test func test_setPreset_ignored_when_running() {
        cleanUserDefaults()
        let model = PomodoroModel()
        model.start()
        let originalMinutes = model.selectedMinutes
        
        model.setPreset(minutes: 10)
        #expect(model.selectedMinutes == originalMinutes)
        
        model.pause()
        model.setPreset(minutes: 10)
        #expect(model.selectedMinutes == 10.0)
    }
}
