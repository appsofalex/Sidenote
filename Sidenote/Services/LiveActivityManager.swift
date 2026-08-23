import ActivityKit
import Foundation

@MainActor
@Observable
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private(set) var liveEntryID: UUID?

    private init() {
        if let stored = AppGroup.defaults.string(forKey: SettingsKey.liveEntryID) {
            liveEntryID = UUID(uuidString: stored)
        }
        Task { await restore() }
    }

    func isLive(_ entryID: UUID) -> Bool {
        liveEntryID == entryID
    }

    func start(entry: SidenoteEntry, settings: SidenoteSettings) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        await stopAll()

        let attributes = SidenoteActivityAttributes(entryId: entry.id)
        let state = SidenoteActivityAttributes.ContentState(
            text: entry.text,
            font: settings.font,
            textSize: settings.textSize,
            appearance: settings.liveAppearance
        )
        let content = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(8 * 60 * 60)
        )

        do {
            _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
            liveEntryID = entry.id
            persist()
            HapticManager.goLive()
        } catch {
            liveEntryID = nil
            persist()
        }
    }

    func stop() async {
        await stopAll()
        HapticManager.stopLive()
    }

    func stopIfEntry(_ id: UUID) async {
        guard liveEntryID == id else { return }
        await stop()
    }

    func update(entry: SidenoteEntry, settings: SidenoteSettings) async {
        guard liveEntryID == entry.id else { return }
        let state = SidenoteActivityAttributes.ContentState(
            text: entry.text,
            font: settings.font,
            textSize: settings.textSize,
            appearance: settings.liveAppearance
        )
        let content = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(8 * 60 * 60)
        )
        for activity in Activity<SidenoteActivityAttributes>.activities where activity.attributes.entryId == entry.id {
            await activity.update(content)
        }
    }

    func refreshRunning(settings: SidenoteSettings, text: String) async {
        guard let liveEntryID else { return }
        let state = SidenoteActivityAttributes.ContentState(
            text: text,
            font: settings.font,
            textSize: settings.textSize,
            appearance: settings.liveAppearance
        )
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(8 * 60 * 60))
        for activity in Activity<SidenoteActivityAttributes>.activities where activity.attributes.entryId == liveEntryID {
            await activity.update(content)
        }
    }

    func restore() async {
        let activities = Activity<SidenoteActivityAttributes>.activities
        if let activity = activities.first {
            liveEntryID = activity.attributes.entryId
            persist()
            for extra in activities.dropFirst() {
                await extra.end(nil, dismissalPolicy: .immediate)
            }
        } else {
            liveEntryID = nil
            persist()
        }
    }

    private func stopAll() async {
        for activity in Activity<SidenoteActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        liveEntryID = nil
        persist()
    }

    private func persist() {
        if let liveEntryID {
            AppGroup.defaults.set(liveEntryID.uuidString, forKey: SettingsKey.liveEntryID)
        } else {
            AppGroup.defaults.removeObject(forKey: SettingsKey.liveEntryID)
        }
    }
}
