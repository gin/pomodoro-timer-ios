import SwiftUI
import UniformTypeIdentifiers

struct SoundPickerView: View {
    @ObservedObject var soundManager: SoundManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("System Sounds")) {
                    ForEach(defaultSystemSounds) { sound in
                        HStack {
                            Text(sound.name)
                            Spacer()
                            if !soundManager.isCustomSound && soundManager.selectedSystemSoundID == sound.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            soundManager.selectSystemSound(id: sound.id)
                            soundManager.previewSystemSound(id: sound.id)
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
                        HStack {
                            Text("Custom Audio File")
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.yellow)
                        }
                        .onTapGesture {
                            if let url = soundManager.customSoundURL {
                                soundManager.previewCustomSound(url: url)
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
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
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
}
