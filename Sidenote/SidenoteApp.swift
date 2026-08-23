import SwiftData
import SwiftUI

@main
struct SidenoteApp: App {
    @State private var settings = SidenoteSettings()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(settings)
                .preferredColorScheme(settings.appearance.colorScheme)
        }
        .modelContainer(for: SidenoteEntry.self)
    }
}
