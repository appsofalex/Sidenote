import SwiftData
import SwiftUI
import TipKit

@main
struct SidenoteApp: App {
    @State private var settings = SidenoteSettings()

    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
        ])
        if AppGroup.defaults.bool(forKey: SettingsKey.hasCreatedNote) {
            FirstUseTips.hasCreatedNote = true
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(settings)
                .preferredColorScheme(settings.appearance.colorScheme)
        }
        .modelContainer(for: SidenoteEntry.self)
    }
}
