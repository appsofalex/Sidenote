import ActivityKit
import SwiftData
import SwiftUI
import TipKit

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
    @State private var scrollOffsetY: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var pendingScrollID: UUID?
    @State private var lastBackground: Date?
    @State private var preservePositionOnReturn = false
    @State private var liveActivitiesUnavailable = false
    @State private var liveManager = LiveActivityManager.shared
    @State private var onboardingTips = TipGroup(.ordered) {
        ScrollUpTip()
        GoLiveTip()
    }

    /// Extra space below the capture viewport so day headers never peek on any phone size.
    private let earlierNotesInset: CGFloat = 88

    private var groups: [DayGroup] {
        StreamGrouping.groups(from: entries)
    }

    private func captureHideThreshold(for height: CGFloat) -> CGFloat {
        // Hide when the day heading reaches the prompt — not the first timestamp below it.
        // Matches DayHeader bottom padding + heading height + EntryRow top padding.
        let firstTimestampLeadIn: CGFloat = 4 + 14 + 18
        return max(120, height * 0.5 + earlierNotesInset * 0.75 - firstTimestampLeadIn)
    }

    private func capturePromptVisible(for height: CGFloat) -> Bool {
        isCaptureFocused || scrollOffsetY < captureHideThreshold(for: height)
    }

    var body: some View {
        NavigationStack {
            scrollSurface
                .background(Color(uiColor: .systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        shareControl
                    }

                    ToolbarItem(placement: .principal) {
                        Text("Sidenote")
                            .font(.system(.title3, weight: .semibold))
                            .opacity(isCaptureFocused ? 0.45 : 1)
                            .animation(.easeInOut(duration: 0.2), value: isCaptureFocused)
                    }

                    if scrolledIntoPast {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Search", systemImage: "magnifyingglass") {
                                showSearch = true
                            }
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showRemoved = true
                            } label: {
                                Label("Recently Removed", systemImage: "trash")
                            }
                            Button("Settings", systemImage: "gear") {
                                showSettings = true
                            }
                            .labelStyle(.titleAndIcon)
                        } label: {
                            Label("More", systemImage: "ellipsis")
                        }
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .animation(.easeInOut(duration: 0.2), value: scrolledIntoPast)
        }
        .safeAreaInset(edge: .bottom) {
            Group {
                if isCaptureFocused {
                    DoneButton(action: commit)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !entries.isEmpty, let tip = onboardingTips.currentTip {
                    TipView(tip)
                        .tipBackground(Color(uiColor: .secondarySystemGroupedBackground))
                        .tipCornerRadius(20, antialiased: true)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id(tip.id)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: isCaptureFocused)
            .animation(.easeInOut(duration: 0.22), value: entries.isEmpty)
        }
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
            Text("Turn on Live Activities for Sidenote in iOS Settings → Sidenote to keep a thought on the Lock Screen. Then long-press a note and tap Go Live.")
        }
        .onChange(of: draft) { _, newValue in
            DraftStore.save(newValue)
        }
        .onChange(of: scenePhase, handleScenePhase)
        .onChange(of: settings.font) { _, _ in
            refreshLive()
            WidgetSync.update(latestEntry: entries.first, settings: settings)
        }
        .onChange(of: settings.textSize) { _, _ in
            refreshLive()
            WidgetSync.update(latestEntry: entries.first, settings: settings)
        }
        .onChange(of: settings.liveAppearance) { _, _ in refreshLive() }
        .onChange(of: entries.count) { _, _ in
            WidgetSync.update(latestEntry: entries.first, settings: settings)
        }
        .onAppear {
            RemovedPurger.purge(in: modelContext)
            WidgetSync.update(latestEntry: entries.first, settings: settings)
            if !entries.isEmpty {
                markHasCreatedNote()
            }
        }
        .onOpenURL(perform: handleURL)
    }

    @ViewBuilder
    private var shareControl: some View {
        if entries.isEmpty {
            Button("Share", systemImage: "square.and.arrow.up") {}
                .disabled(true)
                .opacity(0.28)
        } else {
            ShareLink(
                item: ExportService.plainText(entries: entries),
                preview: SharePreview("Sidenote", icon: Image("ShareIcon"))
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }

    private var scrollSurface: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let promptVisible = capturePromptVisible(for: height)
            let atCaptureHome = scrollOffsetY < 12

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        CaptureSurface(
                            text: $draft,
                            isFocused: $isCaptureFocused,
                            droppingText: droppingText,
                            dropProgress: dropProgress,
                            isPromptVisible: promptVisible,
                            canActivate: promptVisible,
                            allowsExpandedTap: atCaptureHome,
                            onActivate: {
                                guard scrollOffsetY > 12 else { return }
                                returnNotesToHome(using: proxy)
                            },
                            font: settings.captureFont,
                            uiFont: settings.captureUIFont
                        )
                        .containerRelativeFrame(.vertical)
                        .id("home")

                        // Keep the stream out of layout while capturing so it can't
                        // reflow into the gap above the rising Done/keyboard.
                        if !isCaptureFocused {
                            Color.clear
                                .frame(height: earlierNotesInset)
                                .accessibilityHidden(true)

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
                    .transaction(value: isCaptureFocused) { $0.animation = nil }
                }
                .scrollDisabled(isCaptureFocused)
                .scrollDismissesKeyboard(.interactively)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y }) { _, y in
                    scrollOffsetY = max(0, y)
                    scrolledIntoPast = y > 80
                    if y > 48 {
                        ScrollUpTip().invalidate(reason: .actionPerformed)
                    }
                }
                .onChange(of: isCaptureFocused) { _, focused in
                    if focused {
                        returnNotesToHome(using: proxy, animated: false)
                    }
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
                    viewportHeight = height
                    returnNotesToHome(using: proxy, animated: false)
                }
                .onChange(of: height) { _, newHeight in
                    viewportHeight = newHeight
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: capturePromptVisible(for: viewportHeight))
    }

    private func returnNotesToHome(using proxy: ScrollViewProxy, animated: Bool = true) {
        let scroll = {
            proxy.scrollTo("home", anchor: .top)
        }

        if animated {
            withAnimation(.easeInOut(duration: 0.35)) {
                scroll()
            }
        } else {
            scroll()
        }
    }

    private func commit() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        dismissCapture()

        guard !trimmed.isEmpty else {
            draft = ""
            DraftStore.clear()
            return
        }

        HapticManager.commit()
        let entry = SidenoteEntry(text: trimmed)
        modelContext.insert(entry)
        try? modelContext.save()
        DraftStore.clear()
        WidgetSync.update(latestEntry: entry, settings: settings)
        markHasCreatedNote()

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

    private func dismissCapture() {
        isCaptureFocused = false
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func remove(_ entry: SidenoteEntry) {
        let id = entry.id
        entry.deletedAt = .now
        try? modelContext.save()
        HapticManager.remove()
        Task { await liveManager.stopIfEntry(id) }
        let nextLatest = entries.first(where: { $0.id != id })
        WidgetSync.update(latestEntry: nextLatest, settings: settings)
    }

    private func goLive(_ entry: SidenoteEntry) {
        Task {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                liveActivitiesUnavailable = true
                return
            }
            await liveManager.start(entry: entry, settings: settings)
            GoLiveTip().invalidate(reason: .actionPerformed)
        }
    }

    private func refreshLive() {
        guard let id = liveManager.liveEntryID,
              let entry = entries.first(where: { $0.id == id }) else { return }
        Task { await liveManager.update(entry: entry, settings: settings) }
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

    private func markHasCreatedNote() {
        AppGroup.defaults.set(true, forKey: SettingsKey.hasCreatedNote)
        FirstUseTips.hasCreatedNote = true
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
