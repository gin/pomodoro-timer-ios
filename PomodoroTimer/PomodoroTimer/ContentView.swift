//
//  ContentView.swift
//  PomodoroTimer
//
//  Created by luigi on 12/28/25.
//

import SwiftUI

//// For the Cancel/Set buttons to be similar to iOS Alarm Clock's
//// Check: Access UIKit
//struct CircularBarButton: UIViewRepresentable {
//    let systemName: String
//    let action: () -> Void
//    let bgColor: UIColor
//    let fgColor: UIColor
//
//    func makeUIView(context: Context) -> UIButton {
//        let button = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
//        let img = UIImage(systemName: systemName, withConfiguration: config)
//
//        button.setImage(img, for: .normal)
//        button.tintColor = fgColor
//        button.backgroundColor = bgColor
//
//        button.layer.cornerRadius = 20
//        button.clipsToBounds = true
//        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//
//        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
//
//        return button
//    }
//
//    func updateUIView(_ uiView: UIButton, context: Context) {}
//}

struct ContentView: View {
    @State private var model = PomodoroModel()
    @AppStorage("isBlackBackground") private var isBlackBackground = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                if isBlackBackground {
                    Color.black.ignoresSafeArea()
                } else {
                    backgroundGradient.ignoresSafeArea()
                }

                // Grey progress overlay (from left to right)
                HStack(spacing: 0) {
                    Color.gray.opacity(0.6)
                        .frame(width: geometry.size.width * model.progress)
                        .animation(.linear(duration: 1), value: model.progress)
                    Spacer(minLength: 0)
                }
                .ignoresSafeArea()
                
                // Settings Toggle
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isBlackBackground.toggle()
                        } label: {
                            Image(systemName: isBlackBackground ? "paintpalette.fill" : "paintpalette")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                                .opacity(0.6)
                        }
                        .padding()
                    }
                    Spacer()
                }

                // Main content
                VStack(spacing: 24) {
                    Text(phaseTitle)
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .foregroundColor(.white)

                    Text(displayTime)
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    // Preset buttons
                    presetButtonsView
                        .padding(.vertical, 10)

                    // Control buttons
                    HStack(spacing: 20) {
                        Button(model.isRunning ? "Pause" : "Start") {
                            model.isRunning ? model.pause() : model.start()
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())

                        Button("Reset") {
                            model.reset()
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding()
            }
        }
    }
    
    // Time Preset Buttons
    
    private let presets: [Double] = [0.1, 15, 20, 25, 30] // Add Custom button separately
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    @State private var showCustomPicker = false
    @State private var customMinutes: Int = 25
    
    private var presetButtonsView: some View {
        LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(presets, id: \.self) { minutes in
                presetButton(for: minutes)
            }
            
            // Custom Button
            customButton
        }
        .padding(.horizontal)
        .sheet(isPresented: $showCustomPicker) {
            NavigationStack {
                VStack {
                    Picker("Minutes", selection: $customMinutes) {
                        ForEach(1...180, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                }
                .navigationTitle("Set Duration")
                .navigationBarTitleDisplayMode(.inline)
// Button with text "Cancel" and "Set" in oval
                // .toolbarRole(.editor)
                // .toolbar {
                //     ToolbarItem(placement: .cancellationAction) {
                //         Button("Cancel") {
                //             showCustomPicker = false
                //         }
                //     }
                //     ToolbarItem(placement: .confirmationAction) {
                //         Button("Set") {
                //             model.setPreset(minutes: Double(customMinutes))
                //             showCustomPicker = false
                //         }
                //     }
                // }

// Button with inner circle
                //  .toolbar {
                //      ToolbarItem(placement: .cancellationAction) {
                //          Button {
                //              showCustomPicker = false
                //          } label: {
                //              Image(systemName: "xmark")
                //                  .font(.system(size: 12, weight: .bold))
                //                  .foregroundColor(.secondary)
                //                  .padding(8)
                //                  .background(.ultraThinMaterial, in: Circle())
                //          }
                //      }
                //      ToolbarItem(placement: .confirmationAction) {
                //          Button {
                //              model.setPreset(minutes: Double(customMinutes))
                //              showCustomPicker = false
                //          } label: {
                //              Image(systemName: "checkmark")
                //                  .font(.system(size: 12, weight: .bold))
                //                  .foregroundStyle(.black)
                //                  .padding(8)
                //                  .background(.yellow, in: Circle())
                //          }
                //      }
                //  }

// Button with inner circle (big "set" button)
                // .toolbar {
                //     ToolbarItem(placement: .cancellationAction) {
                //         CircularBarButton(
                //             systemName: "xmark",
                //             action: { showCustomPicker = false },
                //             bgColor: UIColor.systemGray5.withAlphaComponent(0.9),
                //             fgColor: UIColor.secondaryLabel
                //         )
                //     }

                //     ToolbarItem(placement: .confirmationAction) {
                //         CircularBarButton(
                //             systemName: "checkmark",
                //             action: {
                //                 model.setPreset(minutes: Double(customMinutes))
                //                 showCustomPicker = false
                //             },
                //             bgColor: UIColor.systemYellow,
                //             fgColor: UIColor.black
                //         )
                //     }
                // }

// Button that is decent but not the same as iOS Alarm Clock's color
                 .toolbar {
                     ToolbarItem(placement: .cancellationAction) {
                         Button {
                             showCustomPicker = false
                         } label: {
                             Image(systemName: "xmark")
                         }
                         .buttonStyle(.borderedProminent)
                         .tint(.secondary)
                     }
                     ToolbarItem(placement: .confirmationAction) {
                         Button {
                             model.setPreset(minutes: Double(customMinutes))
                             showCustomPicker = false
                         } label: {
                             Image(systemName: "checkmark")
                         }
                         .buttonStyle(.borderedProminent)
                         .tint(.yellow)
                     }
                 }
                 
                .presentationDetents([.height(300)])
            }
        }
    }
    
    private var customButton: some View {
        let isCustom = !presets.contains(model.selectedMinutes)
        
        return Button {
            // Ensure we default to at least 1 minute for the picker
            customMinutes = max(1, Int(model.selectedMinutes))
            showCustomPicker = true
        } label: {
            Text(isCustom ? "\(Int(model.selectedMinutes))min" : "Custom")
                .font(.subheadline)
                .fontWeight(isCustom ? .semibold : .regular)
                .foregroundColor(isCustom ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(presetBackground(isSelected: isCustom))
                .clipShape(Capsule())
                .overlay(presetBorder(isSelected: isCustom))
        }
        .disabled(model.isRunning)
        .opacity(model.isRunning ? 0.5 : 1.0)
    }
    
    private func presetButton(for minutes: Double) -> some View {
        let isSelected = model.selectedMinutes == minutes
        
        return Button {
            model.setPreset(minutes: minutes)
        } label: {
            Text(presetLabel(for: minutes))
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(presetBackground(isSelected: isSelected))
                .clipShape(Capsule())
                .overlay(presetBorder(isSelected: isSelected))
        }
        .disabled(model.isRunning)
        .opacity(model.isRunning ? 0.5 : 1.0)
    }
    
    private func presetLabel(for minutes: Double) -> String {
        if minutes >= 1 && minutes.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(minutes))min"
        } else {
            return String(format: "%.1fmin", minutes)
        }
    }
    
    private func presetBackground(isSelected: Bool) -> some ShapeStyle {
        isSelected ? AnyShapeStyle(Color.white.opacity(0.3)) : AnyShapeStyle(.ultraThinMaterial)
    }
    
    private func presetBorder(isSelected: Bool) -> some View {
        Capsule().stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: 1)
    }
    
    // Display Helpers
    
    private var displayTime: String {
        // Show selected preset when not running and no time remaining
        if !model.isRunning && model.remaining == 0 {
            return timeString(from: Int(model.selectedMinutes * 60))
        }
        return timeString(from: model.remaining)
    }

    private var phaseTitle: String {
        switch model.phase {
        case .work:
            return "Work"
        case .rest:
            return "Break"
        case .stopped:
            return "Ready"
        }
    }

    private var backgroundGradient: LinearGradient {
        switch model.phase {
        case .work, .stopped:
            return LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "44a08d")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rest:
            return LinearGradient(
                colors: [Color(hex: "4ecdc4"), Color(hex: "44a08d")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
