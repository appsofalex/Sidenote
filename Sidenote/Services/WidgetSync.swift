import Foundation

enum WidgetSync {
    static func update(latestEntry: SidenoteEntry?, settings: SidenoteSettings) {
        guard let latestEntry else {
            WidgetDataStore.save(.empty)
            return
        }

        WidgetDataStore.save(
            WidgetSnapshot(
                entryID: latestEntry.id,
                text: latestEntry.text,
                font: settings.font,
                textSize: settings.textSize,
                updatedAt: .now
            )
        )
    }
}
