import Testing
import Foundation
@testable import PomodoroTimer

@MainActor
struct SoundManagerTests {
    // Helper to clean up UserDefaults before each test
    private func cleanUserDefaults() {
        let keys = ["selectedSystemSoundID", "isCustomSound", "customSoundFilename"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    @Test func initial_state_should_have_default_values_and_system_sound_tone() {
        cleanUserDefaults()
        let manager = SoundManager()
        #expect(manager.selectedSystemSoundID == 1304)
        #expect(manager.isCustomSound == false)
        #expect(manager.customSoundURL == nil)
        #expect(manager.customSoundFilename == nil)
    }

    @Test func selected_system_sound_id_should_persist() {
        cleanUserDefaults()
        let manager = SoundManager()
        manager.selectSystemSound(id: 1320)
        
        #expect(UserDefaults.standard.integer(forKey: "selectedSystemSoundID") == 1320)
        
        let newManager = SoundManager()
        #expect(newManager.selectedSystemSoundID == 1320)
    }

    @Test func custom_sound_settings_should_persist() {
        cleanUserDefaults()
        let manager = SoundManager()
        manager.isCustomSound = true
        manager.customSoundFilename = "test_alert.m4a"
        
        #expect(UserDefaults.standard.string(forKey: "customSoundFilename") == "test_alert.m4a")
        
        let newManager = SoundManager()
        #expect(newManager.customSoundFilename == "test_alert.m4a")
        
        #expect(UserDefaults.standard.bool(forKey: "isCustomSound") == true)
        #expect(newManager.isCustomSound == true)
    }

    @Test func selecting_system_sound_should_update_id_and_clear_custom_flag() {
        cleanUserDefaults()
        let manager = SoundManager()
        manager.isCustomSound = true
        
        manager.selectSystemSound(id: 1321)
        #expect(manager.selectedSystemSoundID == 1321)
        #expect(manager.isCustomSound == false)
    }

    @Test func setting_custom_sound_url_should_enable_custom_mode() {
        cleanUserDefaults()
        let manager = SoundManager()
        #expect(manager.isCustomSound == false)
        
        let mockURL = URL(fileURLWithPath: "/tmp/mock_alert.m4a")
        manager.customSoundURL = mockURL
        
        #expect(manager.isCustomSound == true)
        #expect(manager.customSoundURL == mockURL)
    }
}
