//
//  PomodoroTimerApp.swift
//  PomodoroTimer
//
//  Created by luigi on 12/28/25.
//

import SwiftUI
import UIKit

@main
struct PomodoroTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
    }
}
