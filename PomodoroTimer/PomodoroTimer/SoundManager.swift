import Foundation
import AVFoundation
import AudioToolbox
import SwiftUI

import Combine

// Default system sounds (ID, Name)
// IDs from http://iphonedevwiki.net/index.php/AudioServices
public struct SystemSound: Identifiable, Hashable {
    public let id: SystemSoundID
    public let name: String
    
    // Explicit id for Identifiable
    public var uuid: String { name }
}

public let defaultSystemSounds: [SystemSound] = [
    SystemSound(id: 1304, name: "Tone"),
    SystemSound(id: 1320, name: "Anticipate"),
    SystemSound(id: 1321, name: "Bloom"),
    SystemSound(id: 1322, name: "Calypso"),
    SystemSound(id: 1323, name: "Choo Choo"),
    SystemSound(id: 1324, name: "Descent"),
    SystemSound(id: 1325, name: "Fanfare"),
    SystemSound(id: 1326, name: "Ladder"),
    SystemSound(id: 1327, name: "Minuet"),
    SystemSound(id: 1328, name: "News Flash"),
    SystemSound(id: 1329, name: "Noir"),
    SystemSound(id: 1330, name: "Sherwood Forest"),
    SystemSound(id: 1331, name: "Spell"),
    SystemSound(id: 1332, name: "Suspense"),
    SystemSound(id: 1333, name: "Telegraph"),
    SystemSound(id: 1334, name: "Tiptoes"),
    SystemSound(id: 1335, name: "Typewriters"),
    SystemSound(id: 1336, name: "Update"),
]

@MainActor
class SoundManager: ObservableObject {
    @Published var selectedSystemSoundID: SystemSoundID = 1304
    @Published var isCustomSound: Bool = false
    @Published var customSoundFilename: String? // e.g. "custom_alert.m4a"
    
    @Published var customSoundURL: URL? {
        didSet {
            if let _ = customSoundURL {
                isCustomSound = true
            }
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load defaults
        let savedID = UserDefaults.standard.integer(forKey: "selectedSystemSoundID")
        self.selectedSystemSoundID = savedID == 0 ? 1304 : SystemSoundID(savedID)
        
        self.isCustomSound = UserDefaults.standard.bool(forKey: "isCustomSound")
        self.customSoundFilename = UserDefaults.standard.string(forKey: "customSoundFilename")
        
        // Attempt to locate existing custom sound file
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if let filename = customSoundFilename {
            // Load specific filename
            let destination = documents.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: destination.path) {
                self.customSoundURL = destination
            }
        } else {
            // Legacy Fallback: Check for constant "custom_alert.mp3"
            let legacyDestination = documents.appendingPathComponent("custom_alert.mp3")
            if FileManager.default.fileExists(atPath: legacyDestination.path) {
                self.customSoundURL = legacyDestination
                self.customSoundFilename = "custom_alert.mp3" // Migrate
            } else {
                if isCustomSound { isCustomSound = false }
            }
        }
        
        // Setup Persistence
        $selectedSystemSoundID
            .sink { id in
                UserDefaults.standard.set(id, forKey: "selectedSystemSoundID")
            }
            .store(in: &cancellables)
        
        $isCustomSound
            .sink { isCustom in
                UserDefaults.standard.set(isCustom, forKey: "isCustomSound")
            }
            .store(in: &cancellables)
            
        $customSoundFilename
            .sink { filename in
                UserDefaults.standard.set(filename, forKey: "customSoundFilename")
            }
            .store(in: &cancellables)

    }
    
    // Playback
    
    // Mapping from SystemSoundID to filenames
    private let systemSoundMap: [SystemSoundID: String] = [
        1304: "alarm.caf",
        1320: "Anticipate.caf",
        1321: "Bloom.caf",
        1322: "Calypso.caf",
        1323: "Choo_Choo.caf",
        1324: "Descent.caf",
        1325: "Fanfare.caf",
        1326: "Ladder.caf",
        1327: "Minuet.caf",
        1328: "News_Flash.caf",
        1329: "Noir.caf",
        1330: "Sherwood_Forest.caf",
        1331: "Spell.caf",
        1332: "Suspense.caf",
        1333: "Telegraph.caf",
        1334: "Tiptoes.caf",
        1335: "Typewriters.caf",
        1336: "Update.caf"
    ]
    
    func playAlert() {
        stopPlaying() // Stop any current sound
        
        if isCustomSound, let url = customSoundURL {
            playCustomSound(url: url)
        } else {
            playSystemSound(id: selectedSystemSoundID)
        }
    }
    
    func previewSystemSound(id: SystemSoundID) {
        stopPlaying() // Stop any current sound
        playSystemSound(id: id)
    }
    
    func previewCustomSound(url: URL) {
        stopPlaying()
        playCustomSound(url: url)
    }
    
    private func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func playSystemSound(id: SystemSoundID) {
        // Attempt to play via AVAudioPlayer for control (stop previous)
        if let filename = systemSoundMap[id], let url = findSystemSoundURL(filename: filename) {
             playAudio(url: url)
        } else {
            // Fallback to simple fire-and-forget
            AudioServicesPlaySystemSound(id)
        }
        
        // Vibration (always)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func findSystemSoundURL(filename: String) -> URL? {
        let fileManager = FileManager.default
        let systemSoundsPath = URL(fileURLWithPath: "/System/Library/Audio/UISounds")
        
        // Check root and subdirectories like "Modern"
        let searchPaths = [
            systemSoundsPath,
            systemSoundsPath.appendingPathComponent("Modern"),
            systemSoundsPath.appendingPathComponent("New"),
            systemSoundsPath.appendingPathComponent("Nano")
        ]
        
        for path in searchPaths {
            let fileURL = path.appendingPathComponent(filename)
            if fileManager.fileExists(atPath: fileURL.path) {
                return fileURL
            }
        }
        return nil
    }
    
    private func playCustomSound(url: URL) {
        playAudio(url: url)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func playAudio(url: URL) {
        do {
            // Ensure session is active for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    // File Management
    
    func selectSystemSound(id: SystemSoundID) {
        selectedSystemSoundID = id
        isCustomSound = false
    }
    
    func importSound(from url: URL) {
        // Securely access the file
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let fileManager = FileManager.default
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // Preserve original extension
            let extensionName = url.pathExtension.isEmpty ? "mp3" : url.pathExtension
            let newFilename = "custom_alert.\(extensionName)"
            let destination = documents.appendingPathComponent(newFilename)
            
            // Clean up ANY existing custom file to avoid clutter/confusion
            if let oldFilename = customSoundFilename {
                let oldPath = documents.appendingPathComponent(oldFilename)
                 if fileManager.fileExists(atPath: oldPath.path) {
                     try? fileManager.removeItem(at: oldPath)
                 }
            } else {
                 // Try removing legacy default just in case
                 let legacyPath = documents.appendingPathComponent("custom_alert.mp3")
                 if fileManager.fileExists(atPath: legacyPath.path) {
                     try? fileManager.removeItem(at: legacyPath)
                 }
            }
            
            // Remove destination if it happens to exist
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            
            // Copy
            try fileManager.copyItem(at: url, to: destination)
            
            // Update
            customSoundFilename = newFilename
            customSoundURL = destination
            
        } catch {
            print("Error importing sound: \(error)")
        }
    }
}
