import ActivityKit
import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(SidenoteSettings.self) private var settings

    @Query(
        filter: #Predicate<SidenoteEntry> { $0.deletedAt == nil },
        sort: \SidenoteEntry.createdAt,
        order: .reverse
    )
    private var entries: [SidenoteEntry]

    @State private var draft = DraftStore.load()
    @State private var isCaptureFocused = false
    @State private var droppingText: String?
    @State private var dropProgress: CGFloat = 0
    @State private var showSettings = false
    @State private var showRemoved = false
    @State private var showSearch = false
    @State private var editingEntry: SidenoteEntry?
    @State private var sharePayload: SharePayload?
    @State private var scrolledIntoPast = false
    @State private var hasDiscoveredEarlier = AppGroup.defaults.bool(forKey: SettingsKey.discoveredEarlier)
    @State private var pendingScrollID: UUID?
    @State private var lastBackground: Date?
    @State private var preservePositionOnReturn = false
    @State private var liveActivitiesUnavailable = false
    @State private var liveManager = LiveActivityManager.shared

    private var groups: [DayGroup] {
        StreamGrouping.groups(from: entries)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                scrollSurface
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isCaptureFocused {
                DoneButton(action: commit)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isCaptureFocused)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(settings)
        }
        .sheet(isPresented: $showRemoved) {
            RecentlyRemovedView()
        }
        .sheet(isPresented: $showSearch) {
            SearchView(entries: entries) { entry in
                showSearch = false
                pendingScrollID = entry.id
            }
        }
        .sheet(item: $editingEntry) { entry in
            EditEntryView(entry: entry)
                .environment(settings)
        }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.text])
                .presentationDetents([.medium, .large])
        }
        .alert("Live Activities are off", isPresented: $liveActivitiesUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Turn on Live Activities for Sidenote in Settings to keep a thought on the Lock Screen.")
        }
        .onChange(of: draft) { _, newValue in
            DraftStore.save(newValue)
        }
        .onChange(of: scenePhase, handleScenePhase)
        .onChange(of: settings.font) { _, _ in refreshLive() }
        .onChange(of: settings.textSize) { _, _ in refreshLive() }
        .onChange(of: settings.liveAppearance) { _, _ in refreshLive() }
        .onAppear {
            RemovedPurger.purge(in: modelContext)
        }
        .onOpenURL(perform: handleURL)
    }

    private var header: some View {
        HStack {
            if entries.isEmpty {
                CircleIconButton(action: {}, accessibilityLabel: "Share") {
                    Image(systemName: "square.and.arrow.up")
                }
                .opacity(0.28)
                .disabled(true)
            } else {
                ShareLink(
                    item: ExportService.plainText(entries: entries),
                    preview: SharePreview("Sidenote")
                ) {
                    CircleIconVisual(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share")
            }

            Spacer(minLength: 8)

            Text("Sidenote")
                .font(.system(.title3, weight: .semibold))
                .opacity(isCaptureFocused ? 0.45 : 1)

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                if scrolledIntoPast {
                    CircleIconButton(action: { showSearch = true }, accessibilityLabel: "Search") {
                        Image(systemName: "magnifyingglass")
                    }
                    .transition(.opacity)
                }

                Menu {
                    Button {
                        showRemoved = true
                    } label: {
                        Label("Recently Removed", systemImage: "clock.arrow.counterclockwise")
                    }
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                } label: {
                    CircleIconVisual(systemName: "ellipsis")
                }
                .accessibilityLabel("More")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: scrolledIntoPast)
        .animation(.easeInOut(duration: 0.2), value: isCaptureFocused)
    }

    private var scrollSurface: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CaptureSurface(
                        text: $draft,
                        isFocused: $isCaptureFocused,
                        droppingText: droppingText,
                        dropProgress: dropProgress,
                        showEarlierCue: showEarlierCue,
                        font: settings.captureFont,
                        uiFont: settings.captureUIFont
                    )
                    .containerRelativeFrame(.vertical)
                    .id("capture")

                    ThoughtStream(
                        groups: groups,
                        isEmpty: entries.isEmpty,
                        liveEntryID: liveManager.liveEntryID,
                        streamFont: settings.streamFont,
                        timestampFont: settings.timestampFont,
                        headingFont: settings.headingFont,
                        onEdit: { editingEntry = $0 },
                        onShare: { sharePayload = SharePayload(text: $0.text) },
                        onRemove: remove,
                        onGoLive: goLive,
                        onStopLive: { entry in
                            Task { await liveManager.stopIfEntry(entry.id) }
                        }
                    )
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y }) { _, y in
                scrolledIntoPast = y > 80
                if y > 120 { markDiscovered() }
            }
            .onChange(of: pendingScrollID) { _, id in
                guard let id else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                    pendingScrollID = nil
                }
            }
            .onAppear {
                proxy.scrollTo("capture", anchor: .top)
            }
        }
    }

    private var showEarlierCue: Bool {
        !entries.isEmpty && !hasDiscoveredEarlier && !isCaptureFocused && !scrolledIntoPast
    }

    private func commit() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        isCaptureFocused = false

        guard !trimmed.isEmpty else {
            draft = ""
            DraftStore.clear()
            return
        }

        HapticManager.commit()
        modelContext.insert(SidenoteEntry(text: trimmed))
        try? modelContext.save()
        DraftStore.clear()

        if reduceMotion {
            draft = ""
            return
        }

        droppingText = trimmed
        draft = ""
        dropProgress = 0
        withAnimation(.spring(duration: 0.48, bounce: 0.08)) {
            dropProgress = 1
        } completion: {
            droppingText = nil
            dropProgress = 0
        }
    }

    private func remove(_ entry: SidenoteEntry) {
        let id = entry.id
        entry.deletedAt = .now
        try? modelContext.save()
        HapticManager.remove()
        Task { await liveManager.stopIfEntry(id) }
    }

    private func goLive(_ entry: SidenoteEntry) {
        Task {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                liveActivitiesUnavailable = true
                return
            }
            await liveManager.start(entry: entry, settings: settings)
        }
    }

    private func refreshLive() {
        guard let id = liveManager.liveEntryID,
              let entry = entries.first(where: { $0.id == id }) else { return }
        Task { await liveManager.update(entry: entry, settings: settings) }
    }

    private func markDiscovered() {
        guard !hasDiscoveredEarlier else { return }
        hasDiscoveredEarlier = true
        AppGroup.defaults.set(true, forKey: SettingsKey.discoveredEarlier)
    }

    private func handleScenePhase(_ old: ScenePhase, _ phase: ScenePhase) {
        switch phase {
        case .background:
            lastBackground = .now
            preservePositionOnReturn = scrolledIntoPast || editingEntry != nil || isCaptureFocused
            DraftStore.save(draft)
        case .active:
            RemovedPurger.purge(in: modelContext)
            guard let lastBackground else { return }
            let elapsed = Date.now.timeIntervalSince(lastBackground)
            if !(preservePositionOnReturn && elapsed < 90) && !isCaptureFocused {
                pendingScrollID = nil
                scrolledIntoPast = false
            }
        default:
            break
        }
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "sidenote" else { return }
        let idString = url.pathComponents.last ?? url.host
        guard let idString, let id = UUID(uuidString: idString) else { return }
        pendingScrollID = id
    }
}

struct SharePayload: Identifiable {
    let id = UUID()
    let text: String
}

#Preview {
    MainView()
        .environment(SidenoteSettings())
        .modelContainer(PreviewContainer.make())
}
