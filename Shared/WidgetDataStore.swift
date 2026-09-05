import Foundation
import WidgetKit

struct WidgetSnapshot: Codable, Hashable {
    var entryID: UUID?
    var text: String
    var font: SidenoteFontChoice
    var textSize: SidenoteTextSize
    var updatedAt: Date

    static let placeholder = WidgetSnapshot(
        entryID: nil,
        text: "Collect my parcel from the post office after lunch.",
        font: .system,
        textSize: .regular,
        updatedAt: .now
    )

    static let empty = WidgetSnapshot(
        entryID: nil,
        text: "",
        font: .system,
        textSize: .regular,
        updatedAt: .now
    )
}

enum WidgetDataStore {
    static func load() -> WidgetSnapshot {
        guard
            let data = AppGroup.defaults.data(forKey: SettingsKey.widgetSnapshot),
            let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .placeholder
        }
        return snapshot
    }

    static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        AppGroup.defaults.set(data, forKey: SettingsKey.widgetSnapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
