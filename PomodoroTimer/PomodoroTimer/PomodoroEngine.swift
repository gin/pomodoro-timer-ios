//
//  PomodoroEngine.swift
//  PomodoroTimer
//
//  Created by luigi on 12/28/25.
//

public enum PomodoroPhase {
    case work
    case rest
    case stopped
}

public struct PomodoroEngine {
    public private(set) var phase: PomodoroPhase = .stopped
    public private(set) var total: Int = 0
    public private(set) var remaining: Int = 0

    public init() {}

    public mutating func start(work: Int) {
        phase = .work
        total = work
        remaining = work
    }

    public mutating func tick() {
        guard remaining > 0 else { return }
        remaining -= 1
        if remaining == 0 {
            switch phase {
            case .work:
                phase = .rest
                total = total == remaining ? 0 : total
            case .rest:
                phase = .stopped
            case .stopped:
                break
            }
        }
    }

    public mutating func startRest(_ seconds: Int) {
        phase = .rest
        total = seconds
        remaining = seconds
    }

    public mutating func stop() {
        phase = .stopped
        total = 0
        remaining = 0
    }
}
