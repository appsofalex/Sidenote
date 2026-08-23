import Foundation
import SwiftData

enum RemovedPurger {
    static let retention: TimeInterval = 30 * 24 * 60 * 60

    @MainActor
    static func purge(in context: ModelContext) {
        let cutoff = Date().addingTimeInterval(-retention)
        let descriptor = FetchDescriptor<SidenoteEntry>(
            predicate: #Predicate { entry in
                entry.deletedAt != nil
            }
        )
        guard let removed = try? context.fetch(descriptor) else { return }
        var didChange = false
        for entry in removed {
            if let deletedAt = entry.deletedAt, deletedAt < cutoff {
                context.delete(entry)
                didChange = true
            }
        }
        if didChange {
            try? context.save()
        }
    }

    static func daysRemaining(for deletedAt: Date, now: Date = .now) -> Int {
        let remaining = retention - now.timeIntervalSince(deletedAt)
        return max(0, Int(ceil(remaining / 86_400)))
    }
}
