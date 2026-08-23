import Foundation

enum DraftStore {
    static func load() -> String {
        AppGroup.defaults.string(forKey: SettingsKey.draft) ?? ""
    }

    static func save(_ text: String) {
        if text.isEmpty {
            AppGroup.defaults.removeObject(forKey: SettingsKey.draft)
        } else {
            AppGroup.defaults.set(text, forKey: SettingsKey.draft)
        }
    }

    static func clear() {
        AppGroup.defaults.removeObject(forKey: SettingsKey.draft)
    }
}
