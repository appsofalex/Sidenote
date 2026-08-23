import SwiftData
import SwiftUI

enum PreviewContainer {
    static func make(sample: Bool = true) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SidenoteEntry.self, configurations: configuration)
        if sample {
            let context = ModelContext(container)
            for entry in Self.samples {
                context.insert(entry)
            }
        }
        return container
    }

    static var samples: [SidenoteEntry] {
        let calendar = Calendar.current
        let now = Date()
        func hoursAgo(_ hours: Int, minutes: Int = 0) -> Date {
            calendar.date(byAdding: .minute, value: -(hours * 60 + minutes), to: now) ?? now
        }
        func daysAgo(_ days: Int, hour: Int, minute: Int) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            let today = calendar.date(from: components) ?? now
            return calendar.date(byAdding: .day, value: -days, to: today) ?? now
        }

        return [
            SidenoteEntry(text: "Collect the parcel after lunch.", createdAt: hoursAgo(0, minutes: 12), updatedAt: hoursAgo(0, minutes: 12)),
            SidenoteEntry(text: "Ask Sarah about October flights.", createdAt: hoursAgo(2, minutes: 18), updatedAt: hoursAgo(2, minutes: 18)),
            SidenoteEntry(text: "The onboarding shouldn't explain everything. Just get people using it.", createdAt: hoursAgo(4, minutes: 40), updatedAt: hoursAgo(4, minutes: 40)),
            SidenoteEntry(text: "Restaurant Anne mentioned.", createdAt: daysAgo(1, hour: 21, minute: 17), updatedAt: daysAgo(1, hour: 21, minute: 17)),
            SidenoteEntry(text: "Buy coffee beans on the way home.", createdAt: daysAgo(1, hour: 14, minute: 8), updatedAt: daysAgo(1, hour: 14, minute: 8)),
            SidenoteEntry(text: "Look into that quiet hotel near the station.", createdAt: daysAgo(3, hour: 19, minute: 44), updatedAt: daysAgo(3, hour: 19, minute: 44))
        ]
    }
}
