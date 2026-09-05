import SwiftUI
import WidgetKit

struct SidenoteHomeWidget: Widget {
    let kind = "SidenoteHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SidenoteHomeProvider()) { entry in
            SidenoteHomeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Sidenote")
        .description("Your latest sidenote on the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SidenoteHomeEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct SidenoteHomeProvider: TimelineProvider {
    func placeholder(in context: Context) -> SidenoteHomeEntry {
        SidenoteHomeEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SidenoteHomeEntry) -> Void) {
        completion(SidenoteHomeEntry(date: .now, snapshot: WidgetDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SidenoteHomeEntry>) -> Void) {
        let snapshot = WidgetDataStore.load()
        let entry = SidenoteHomeEntry(date: .now, snapshot: snapshot)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct SidenoteHomeWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: SidenoteHomeEntry

    private var snapshot: WidgetSnapshot { entry.snapshot }

    var body: some View {
        Group {
            if snapshot.text.isEmpty {
                emptyView
            } else {
                noteView
            }
        }
        .widgetURL(widgetURL)
    }

    private var widgetURL: URL? {
        guard let entryID = snapshot.entryID else { return URL(string: "sidenote://") }
        return URL(string: "sidenote://entry/\(entryID.uuidString)")
    }

    private var noteView: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 6 : 8) {
            if family == .systemSmall {
                Image(systemName: "text.alignleft")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(snapshot.text)
                .font(
                    SidenoteTypography.font(
                        snapshot.font,
                        size: family == .systemSmall ? 14 : SidenoteTypography.streamSize(snapshot.textSize)
                    )
                )
                .foregroundStyle(.primary)
                .lineLimit(family == .systemSmall ? 4 : 6)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(family == .systemSmall ? 14 : 16)
    }

    private var emptyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "text.alignleft")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)

            Text("Capture a sidenote")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#if DEBUG
#Preview(as: .systemMedium) {
    SidenoteHomeWidget()
} timeline: {
    SidenoteHomeEntry(date: .now, snapshot: .placeholder)
}
#endif
