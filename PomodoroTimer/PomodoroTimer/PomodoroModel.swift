//
//  PomodoroModel.swift
//  PomodoroTimer
//
//  Created by luigi on 12/28/25.
//

import SwiftUI
import Observation

@MainActor
@Observable
class PomodoroModel {
    private var engine = PomodoroEngine()
    private var timer: Timer?
    
    /// Currently selected duration in minutes (supports decimals for testing)
    var selectedMinutes: Double = 25
    
    // Persist work and rest durations
    private var workDurationMinutes: Double {
        get { UserDefaults.standard.double(forKey: "workDurationMinutes") == 0 ? 25 : UserDefaults.standard.double(forKey: "workDurationMinutes") }
        set { UserDefaults.standard.set(newValue, forKey: "workDurationMinutes") }
    }
    
    private var restDurationMinutes: Double {
        get { UserDefaults.standard.double(forKey: "restDurationMinutes") == 0 ? 5 : UserDefaults.standard.double(forKey: "restDurationMinutes") }
        set { UserDefaults.standard.set(newValue, forKey: "restDurationMinutes") }
    }
    
    init() {
        // Load initial work duration
        selectedMinutes = workDurationMinutes
    }

    var remaining: Int { engine.remaining }
    var total: Int { engine.total }
    var phase: PomodoroPhase { engine.phase }
    var isRunning: Bool { timer != nil }
    
    /// Progress from 0.0 (just started) to 1.0 (complete)
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(total - remaining) / Double(total)
    }
    
    /// Set the timer preset without starting (works in stopped or rest phase when paused)
    func setPreset(minutes: Double) {
        guard !isRunning else { return }
        selectedMinutes = minutes
        
        // Save to compatibility storage based on current phase
        if phase == .rest {
            restDurationMinutes = minutes
        } else {
            // Stopped or Work phase implies we are setting Work duration
            workDurationMinutes = minutes
        }
    }

    /// Start or resume timer based on current phase
    func start() {
        if isRunning { return }
        
        let seconds = Int(selectedMinutes * 60)
        
        switch phase {
        case .stopped:
            // Start work session
            engine.start(work: seconds)
        case .rest:
            // Start break with selected preset
            engine.startRest(seconds)
        case .work:
            // Resume work (shouldn't happen normally, but handle it)
            engine.start(work: seconds)
        }
        startTimer()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        engine.stop()
        selectedMinutes = workDurationMinutes  // Reset to saved work duration
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func handleTimer() {
        // We are on the main run loop; class is @MainActor
        engine.tick()
        // Pause when timer reaches 0 (either work→rest or rest→stopped)
        if engine.remaining == 0 {
            pause()
            
            // Auto-switch preset for next phase
            if engine.phase == .rest {
                // Work finished -> Prepare for Break
                selectedMinutes = restDurationMinutes
            } else if engine.phase == .stopped {
                // Break finished -> Prepare for Work
                selectedMinutes = workDurationMinutes
            }
        }
    }
}
