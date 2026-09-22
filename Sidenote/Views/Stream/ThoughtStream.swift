import SwiftData
import SwiftUI

struct EntryRow: View {
    let entry: SidenoteEntry
    var isLive: Bool
    var streamFont: Font
    var timestampFont: Font
    var onEdit: () -> Void
    var onShare: () -> Void
    var onRemove: () -> Void
    var onGoLive: () -> Void
    var onStopLive: () -> Void
    var onToggleBold: () -> Void

    private var isBold: Bool {
        NoteMarkup.isFullyBold(entry.text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(SidenoteDates.time(entry.createdAt))
                    .font(timestampFont)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                if isLive {
                    LiveMark(size: 7)
                        .offset(y: -1)
                        .accessibilityLabel("Live")
                }
            }

            LinkifiedText(text: entry.text, font: streamFont)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .contextMenu {
            if isLive {
                Button {
                    onStopLive()
                } label: {
                    Label("Stop Live", systemImage: "stop.circle")
                }
            } else {
                Button {
                    onGoLive()
                } label: {
                    Label("Go Live", systemImage: "record.circle")
                }
            }

            Button {
                onToggleBold()
            } label: {
                Label(isBold ? "Unbold" : "Bold", systemImage: "bold")
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                onShare()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Divider()

            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Actions available from a long press. Choose Go Live to show this note on the Lock Screen.")
    }
}

struct DayHeader: View {
    var date: Date
    var font: Font

    var body: some View {
        Text(SidenoteDates.heading(for: date))
            .font(font)
            .tracking(1.1)
            .foregroundStyle(.secondary)
            .padding(.top, 28)
            .padding(.bottom, 4)
            .accessibilityAddTraits(.isHeader)
    }
}

struct ThoughtStream: View {
    var groups: [DayGroup]
    var isEmpty: Bool
    var liveEntryID: UUID?
    var streamFont: Font
    var timestampFont: Font
    var headingFont: Font
    var onEdit: (SidenoteEntry) -> Void
    var onShare: (SidenoteEntry) -> Void
    var onRemove: (SidenoteEntry) -> Void
    var onGoLive: (SidenoteEntry) -> Void
    var onStopLive: (SidenoteEntry) -> Void
    var onToggleBold: (SidenoteEntry) -> Void

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if isEmpty {
                Text("Nothing earlier")
                    .font(.footnote)
                    .foregroundStyle(.quaternary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 80)
            } else {
                ForEach(groups) { group in
                    DayHeader(date: group.id, font: headingFont)
                    ForEach(group.entries, id: \.id) { entry in
                        EntryRow(
                            entry: entry,
                            isLive: liveEntryID == entry.id,
                            streamFont: streamFont,
                            timestampFont: timestampFont,
                            onEdit: { onEdit(entry) },
                            onShare: { onShare(entry) },
                            onRemove: { onRemove(entry) },
                            onGoLive: { onGoLive(entry) },
                            onStopLive: { onStopLive(entry) },
                            onToggleBold: { onToggleBold(entry) }
                        )
                        .id(entry.id)
                    }
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 56)
    }
}
