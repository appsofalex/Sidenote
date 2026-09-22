import Foundation
import SwiftData

@Model
final class SidenoteEntry {
    @Attribute(.unique) var id: UUID
    var text: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    init(
        text: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        deletedAt: Date? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    var isRemoved: Bool { deletedAt != nil }

    var preview: String {
        let collapsed = NoteMarkup.plainText(text)
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if collapsed.count <= 120 { return collapsed }
        return String(collapsed.prefix(117)) + "…"
    }
}

struct DayGroup: Identifiable {
    var id: Date
    var entries: [SidenoteEntry]
}

enum StreamGrouping {
    static func groups(from entries: [SidenoteEntry]) -> [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.createdAt) }
        return grouped.keys.sorted(by: >).map { day in
            DayGroup(
                id: day,
                entries: (grouped[day] ?? []).sorted { $0.createdAt > $1.createdAt }
            )
        }
    }
}
