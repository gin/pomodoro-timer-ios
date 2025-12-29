//
//  ContentView.swift
//  PomodoroTimer
//
//  Created by luigi on 12/28/25.
//

import SwiftUI

struct ContentView: View {
    @State private var model = PomodoroModel()

    var body: some View {
        VStack(spacing: 30) {
            Text(model.phase == .work ? "Work" : "Break")
                .font(.largeTitle)

            Text(timeString(from: model.remaining))
                .font(.system(size: 60, weight: .bold, design: .monospaced))

            HStack(spacing: 40) {
                Button(model.isRunning ? "Pause" : "Start") {
                    model.isRunning ? model.pause() : model.start()
                }
                Button("Reset") {
                    model.reset()
                }
            }
        }
        .padding()
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
