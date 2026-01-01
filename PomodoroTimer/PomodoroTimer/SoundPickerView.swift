import SwiftUI
import UniformTypeIdentifiers

struct SoundPickerView: View {
    @ObservedObject var soundManager: SoundManager
    @Binding var isPresented: Bool
    
    @State private var isImporting = false
    
    var body: some View {
        List {
            Section(header: Text("System Sounds")) {
                ForEach(defaultSystemSounds) { sound in
                    Button {
                        soundManager.selectSystemSound(id: sound.id)
                        soundManager.previewSystemSound(id: sound.id)
                    } label: {
                        HStack {
                            Text(sound.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if !soundManager.isCustomSound && soundManager.selectedSystemSoundID == sound.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Custom")) {
                // Import Button
                Button {
                    isImporting = true
                } label: {
                    Label("Import Sound...", systemImage: "square.and.arrow.down")
                }
                
                // Display selected custom sound if active
                if soundManager.isCustomSound {
                    Button {
                        if let url = soundManager.customSoundURL {
                            soundManager.previewCustomSound(url: url)
                        }
                    } label: {
                        HStack {
                            Text("Custom Audio File")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
        }
        .navigationTitle("Alert Sound")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    soundManager.importSound(from: url)
                    // Auto-preview
                    if let newUrl = soundManager.customSoundURL {
                        soundManager.previewCustomSound(url: newUrl)
                    }
                }
            case .failure(let error):
                print("File import failed: \(error)")
            }
        }
    }
}
