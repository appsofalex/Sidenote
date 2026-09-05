import Foundation

enum AppGroup {
    static let identifier = "group.com.alexanderwalters.sidenote"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

enum SettingsKey {
    static let appearance = "sidenote.appearance"
    static let font = "sidenote.font"
    static let textSize = "sidenote.textSize"
    static let liveAppearance = "sidenote.liveAppearance"
    static let liveEntryID = "sidenote.liveEntryID"
    static let draft = "sidenote.draft"
    static let lastBackgroundDate = "sidenote.lastBackgroundDate"
    static let widgetSnapshot = "sidenote.widgetSnapshot"
}
