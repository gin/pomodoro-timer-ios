import Testing
import Foundation
@testable import PomodoroTimer

struct PomodoroEngineTests {
    @Test func initial_state_should_be_stopped_with_zero_time() {
        var engine = PomodoroEngine()
        #expect(engine.phase == .stopped)
        #expect(engine.remaining == 0)
        #expect(engine.total == 0)
    }

    @Test func start_work_should_initialize_work_phase_and_time() {
        var engine = PomodoroEngine()
        engine.start(work: 1500)
        #expect(engine.phase == .work)
        #expect(engine.total == 1500)
        #expect(engine.remaining == 1500)
    }

    @Test func tick_should_decrement_remaining_time() {
        var engine = PomodoroEngine()
        engine.start(work: 10)
        engine.tick()
        #expect(engine.remaining == 9)
        #expect(engine.total == 10)
    }

    @Test func engine_should_transition_from_work_to_rest_on_completion() {
        var engine = PomodoroEngine()
        engine.start(work: 1)
        engine.tick()
        #expect(engine.phase == .rest)
        #expect(engine.remaining == 0)
        #expect(engine.total == 1)
    }

    @Test func start_rest_should_initialize_rest_phase_and_time() {
        var engine = PomodoroEngine()
        engine.startRest(300)
        #expect(engine.phase == .rest)
        #expect(engine.total == 300)
        #expect(engine.remaining == 300)
    }

    @Test func engine_should_transition_from_rest_to_stopped_on_completion() {
        var engine = PomodoroEngine()
        engine.startRest(1)
        engine.tick()
        #expect(engine.phase == .stopped)
        #expect(engine.remaining == 0)
        #expect(engine.total == 1)
    }

    @Test func stop_should_reset_phase_and_all_times() {
        var engine = PomodoroEngine()
        engine.start(work: 10)
        engine.tick()
        engine.stop()
        #expect(engine.phase == .stopped)
        #expect(engine.remaining == 0)
        #expect(engine.total == 0)
    }

    @Test func tick_at_zero_should_not_change_anything() {
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
    func phase_should_transition_correctly_on_cycle(phase: PomodoroPhase, duration: Int) {
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

    @Test func initial_model_values_should_have_default_values() {
        cleanUserDefaults()
        let model = PomodoroModel()
        #expect(model.selectedMinutes == 25.0)
        #expect(model.phase == .stopped)
        #expect(model.isRunning == false)
    }

    @Test func progress_should_be_calculated_correctly() {
        cleanUserDefaults()
        let model = PomodoroModel()
        model.setPreset(minutes: 10) // 600 seconds
        
        // At start (0/600 processed)
        #expect(model.progress == 0.0)
    }

    @Test func work_duration_should_persist_in_user_defaults() {
        cleanUserDefaults()
        let model = PomodoroModel()
        model.setPreset(minutes: 45)
        
        #expect(UserDefaults.standard.double(forKey: "workDurationMinutes") == 45.0)
        
        let newModel = PomodoroModel()
        #expect(newModel.selectedMinutes == 45.0)
    }

    @Test(.disabled("Needs mock to test in rest state, or test in UI test"))
    func rest_duration_should_persist_in_user_defaults() {}

    @Test func reset_should_stop_timer_and_restore_work_preset() {
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

    @Test func set_preset_should_be_ignored_when_timer_is_running() {
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
