import Foundation

enum SidenoteDates {
    static func heading(for day: Date, now: Date = .now) -> String {
        let calendar = Calendar.current
        if calendar.isDate(day, inSameDayAs: now) {
            return String(localized: "Today").uppercased(with: .current)
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(day, inSameDayAs: yesterday) {
            return String(localized: "Yesterday").uppercased(with: .current)
        }
        return day.formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased(with: .current)
    }

    static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func removedSubtitle(createdAt: Date, deletedAt: Date) -> String {
        let created = createdAt.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        let days = RemovedPurger.daysRemaining(for: deletedAt)
        if days <= 7 {
            return "\(created)  ·  \(days)d left"
        }
        return created
    }
}
