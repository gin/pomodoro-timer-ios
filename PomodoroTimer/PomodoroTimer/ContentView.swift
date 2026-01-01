import SwiftUI

struct ContentView: View {
    @State private var model = PomodoroModel()
    @StateObject private var soundManager = SoundManager()
    @AppStorage("isBlackBackground") private var isBlackBackground = false
    @State private var showSoundPicker = false
    
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
                    HStack(spacing: 12) {
                        Spacer()
                        
                        Button {
                            showSoundPicker = true
                        } label: {
                            Image(systemName: isBlackBackground ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                                .opacity(0.6)
                        }
                        
                        Button {
                            isBlackBackground.toggle()
                        } label: {
                            Image(systemName: isBlackBackground ? "paintpalette.fill" : "paintpalette")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                                .opacity(0.6)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 16)
                    
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
                    HStack(spacing: 160) {
                        Button("Reset") {
                            model.reset()
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 90, height: 90)
                        .background(.ultraThinMaterial, in: Circle())
                        
                        Button(model.isRunning ? "Pause" : "Start") {
                            model.isRunning ? model.pause() : model.start()
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 90, height: 90)
                        .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding()
            }
        }
        
        .onChange(of: model.shouldPlayAlert) {
            if model.shouldPlayAlert {
                soundManager.playAlert()
                model.shouldPlayAlert = false // Reset trigger
            }
        }
        .sheet(isPresented: $showSoundPicker) {
            NavigationStack {
                SoundPickerView(soundManager: soundManager, isPresented: $showSoundPicker)
            }
        }
        .sheet(isPresented: $showCustomPicker) {
            NavigationStack {
                CustomDurationPickerView(
                    customMinutes: $customMinutes,
                    isPresented: $showCustomPicker,
                    onConfirm: { minutes in
                        model.setPreset(minutes: Double(minutes))
                    }
                )
                .presentationDetents([.height(300)])
            }
        }
    }
    
    // Time Preset Buttons
    
    private let presets: [Double] = [10, 30, 60, 5, 15] // Add Custom button separately
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
