import SwiftData
import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SidenoteSettings.self) private var settings

    let entry: SidenoteEntry
    @State private var text: String
    @State private var isFocused = true

    init(entry: SidenoteEntry) {
        self.entry = entry
        _text = State(initialValue: entry.text)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CaptureSurface(
                    text: $text,
                    isFocused: $isFocused,
                    droppingText: nil,
                    dropProgress: 0,
                    font: settings.captureFont,
                    uiFont: settings.captureUIFont
                )
                Spacer(minLength: 0)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                DoneButton(action: save)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 8)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit")
                        .font(.system(.headline, weight: .semibold))
                }
                CloseToolbarButton(action: { dismiss() })
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(false)
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        isFocused = false
        if trimmed.isEmpty {
            dismiss()
            return
        }
        entry.text = trimmed
        entry.updatedAt = .now
        try? modelContext.save()
        Task { await LiveActivityManager.shared.update(entry: entry, settings: settings) }
        if WidgetDataStore.load().entryID == entry.id {
            WidgetSync.update(latestEntry: entry, settings: settings)
        }
        dismiss()
    }
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    var entries: [SidenoteEntry]
    var onSelect: (SidenoteEntry) -> Void
    @State private var query = ""
    @FocusState private var focused: Bool

    private var results: [SidenoteEntry] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return [] }
        return entries.filter { $0.text.localizedStandardContains(needle) }
    }

    var body: some View {
        NavigationStack {
            List {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Search looks through every current sidenote.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else if results.isEmpty {
                    Text("Nothing matches.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(results, id: \.id) { entry in
                        Button {
                            onSelect(entry)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(SidenoteDates.time(entry.createdAt))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(entry.preview)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton(action: { dismiss() })
            }
        }
        .onAppear { focused = true }
    }
}

struct RecentlyRemovedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<SidenoteEntry> { $0.deletedAt != nil },
        sort: \SidenoteEntry.updatedAt,
        order: .reverse
    )
    private var removed: [SidenoteEntry]
    @State private var pendingPermanent: SidenoteEntry?

    private var sorted: [SidenoteEntry] {
        removed.sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sorted.isEmpty {
                    ContentUnavailableView(
                        "Nothing recently removed",
                        systemImage: "clock",
                        description: Text("Removed sidenotes stay here for 30 days.")
                    )
                } else {
                    List {
                        ForEach(sorted, id: \.id) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.preview)
                                    .font(.body)
                                if let deletedAt = entry.deletedAt {
                                    Text(SidenoteDates.removedSubtitle(createdAt: entry.createdAt, deletedAt: deletedAt))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Restore") { restore(entry) }
                                    .tint(.primary)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete Permanently", role: .destructive) {
                                    pendingPermanent = entry
                                }
                            }
                            .contextMenu {
                                Button { restore(entry) } label: {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }
                                Button(role: .destructive) {
                                    pendingPermanent = entry
                                } label: {
                                    Label("Delete Permanently", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Recently Removed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton(action: { dismiss() })
            }
            .confirmationDialog(
                "Delete this sidenote permanently?",
                isPresented: Binding(
                    get: { pendingPermanent != nil },
                    set: { if !$0 { pendingPermanent = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Permanently", role: .destructive) {
                    if let entry = pendingPermanent {
                        deletePermanently(entry)
                    }
                    pendingPermanent = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingPermanent = nil
                }
            }
        }
        .onAppear {
            RemovedPurger.purge(in: modelContext)
        }
    }

    private func restore(_ entry: SidenoteEntry) {
        entry.deletedAt = nil
        entry.updatedAt = .now
        try? modelContext.save()
        HapticManager.restore()
    }

    private func deletePermanently(_ entry: SidenoteEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        HapticManager.permanentDelete()
    }
}
