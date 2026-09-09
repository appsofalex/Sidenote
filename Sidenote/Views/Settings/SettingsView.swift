import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(SidenoteSettings.self) private var settings
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsCard {
                        SettingsRow(systemImage: "circle.lefthalf.filled", title: "Appearance") {
                            Menu {
                                ForEach(AppAppearance.allCases) { option in
                                    Button(option.displayName) { settings.appearance = option }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(settings.appearance.displayName)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }

                        SettingsDivider()

                        NavigationLink {
                            TextSettingsView()
                        } label: {
                            SettingsRow(systemImage: "doc.text", title: "Note Text") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    SettingsCard {
                        NavigationLink {
                            WidgetSettingsView()
                        } label: {
                            SettingsRow(systemImage: "square.grid.2x2", title: "Widget") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsDivider()

                        NavigationLink {
                            LiveActivitySettingsView()
                        } label: {
                            SettingsRow(systemImage: "iphone", title: "Live Activity") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    SettingsCard {
                        Button {
                            if let url = URL(string: "mailto:alexwalters148@gmail.com?subject=Sidenote%20Feedback") {
                                openURL(url)
                            }
                        } label: {
                            SettingsRow(systemImage: "bubble.left", title: "Give Feedback") {
                                EmptyView()
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsDivider()

                        Button {
                            requestReview()
                        } label: {
                            SettingsRow(systemImage: "star", title: "Rate Sidenote") {
                                EmptyView()
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsDivider()

                        NavigationLink {
                            AboutView()
                        } label: {
                            SettingsRow(systemImage: "info.circle", title: "About Sidenote") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    SettingsFooter(versionString: versionString)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton(action: { dismiss() })
            }
        }
        // Sheets don't inherit root preferredColorScheme updates while presented.
        .preferredColorScheme(settings.appearance.colorScheme)
        .id(settings.appearance)
    }

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "Version \(version)"
    }
}

struct TextSettingsView: View {
    @Environment(SidenoteSettings.self) private var settings

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("The quick brown fox jumps over the lazy dog")
                    .font(settings.streamFont)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 36)

                SettingsCard {
                    SettingsRow(systemImage: nil, title: "Font") {
                        Menu {
                            ForEach(SidenoteFontChoice.allCases) { option in
                                Button(option.displayName) { settings.font = option }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(settings.font.displayName)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Size")
                                .font(.body)
                            Picker("Size", selection: Bindable(settings).textSize) {
                                ForEach(SidenoteTextSize.allCases) { size in
                                    Text(size.displayName).tag(size)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }

                    Text("Text size is used in the app, on widgets, and on Live Activities. The preview is not exact.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Note Text")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WidgetSettingsView: View {
    @Environment(SidenoteSettings.self) private var settings

    private let previewText = "Collect my parcel from the post office after lunch."

    var body: some View {
        ScrollView {
            SettingsFeatureCard {
                HomeScreenWidgetPreview(
                    text: previewText,
                    font: settings.streamFont
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Home Screen Widget")
                        .font(.headline)
                    Text("Go to your Home Screen, then tap and hold an empty area until the Edit button appears in the top-left corner. Tap Edit > Add Widget, search for Sidenote, choose a widget size, and tap Add Widget.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Widget")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LiveActivitySettingsView: View {
    @Environment(SidenoteSettings.self) private var settings

    private let previewText = "Collect my parcel from the post office after lunch."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsFeatureCard {
                    LiveActivityPreview(
                        text: previewText,
                        appearance: settings.liveAppearance,
                        animated: true
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Live Activity")
                            .font(.headline)
                        Text("Long-press any sidenote in the stream, then tap Go Live. It appears on the Lock Screen and in the Dynamic Island on supported iPhones for up to 8 hours. Long-press again and tap Stop Live to end it.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("APPEARANCE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)

                    SettingsCard {
                        ForEach(Array(LiveAppearance.allCases.enumerated()), id: \.element.id) { index, option in
                            Button {
                                settings.liveAppearance = option
                            } label: {
                                HStack {
                                    Text(option.displayName)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if settings.liveAppearance == option {
                                        Image(systemName: "checkmark")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(minHeight: 56)
                            }
                            if index < LiveAppearance.allCases.count - 1 {
                                SettingsDivider(leadingInset: 16)
                            }
                        }
                    }

                    Text("Choose how your sidenote looks on the Lock Screen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Live Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Sidenote keeps your thoughts on this iPhone. There is no account, and nothing is sent to a server.")

                VStack(alignment: .leading, spacing: 10) {
                    Text("Features")
                        .font(.headline)
                    labeledFeature(
                        title: "Capture",
                        detail: "Tap the prompt on the home screen, write a thought, then tap Done. Swipe up to browse earlier sidenotes."
                    )
                    labeledFeature(
                        title: "Go Live",
                        detail: "Long-press a sidenote and choose Go Live to show it on the Lock Screen and Dynamic Island. Choose Stop Live to end it."
                    )
                    labeledFeature(
                        title: "Widget",
                        detail: "Add the Sidenote Home Screen widget from the iOS widget gallery. See Settings → Widget for steps."
                    )
                    labeledFeature(
                        title: "Edit, share, remove",
                        detail: "Long-press a sidenote for Edit, Share, or Remove. Removed notes stay on device for 30 days, then are deleted."
                    )
                }
            }
            .font(.body)
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("About Sidenote")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func labeledFeature(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }
}

struct SettingsFeatureCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }
}

struct SettingsDivider: View {
    static let rowLeadingInset: CGFloat = 56

    var leadingInset: CGFloat = SettingsDivider.rowLeadingInset

    var body: some View {
        Divider().padding(.leading, leadingInset)
    }
}

struct SettingsRow<Trailing: View>: View {
    var systemImage: String?
    var title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 14) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .frame(width: 26, alignment: .center)
            }
            Text(title)
                .font(.body)
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 56)
        .contentShape(Rectangle())
    }
}

struct SettingsFooter: View {
    var versionString: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "text.alignleft")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 64, height: 64)
                .background(
                    Color(uiColor: .secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            Text("Sidenote")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(versionString)
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 32)
        .padding(.bottom, 40)
    }
}

struct HomeScreenWidgetPreview: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var text: String
    var font: Font

    @State private var widgetOffset: CGFloat = 0
    @State private var widgetScale: CGFloat = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemFill))

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.primary.opacity(0.85))
                    .frame(width: 92, height: 24)
                    .padding(.top, 16)

                Spacer()

                Text(text)
                    .font(font)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Color(uiColor: .secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                    .padding(.horizontal, 24)
                    .offset(y: widgetOffset)
                    .scaleEffect(widgetScale)

                Spacer()
            }
            .padding(.bottom, 12)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Home Screen widget preview")
        .onAppear(perform: startAnimation)
    }

    private func startAnimation() {
        guard !reduceMotion else { return }

        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            widgetOffset = -8
        }

        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            widgetScale = 1.02
        }
    }
}

struct LiveActivityPreview: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var text: String
    var appearance: LiveAppearance
    var animated: Bool = false

    @State private var bannerOffset: CGFloat = -72
    @State private var bannerOpacity: Double = 0
    @State private var islandExpanded = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemFill))

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.primary.opacity(islandExpanded ? 0.18 : 0.85))
                    .frame(width: islandExpanded ? 180 : 92, height: islandExpanded ? 34 : 24)
                    .overlay {
                        if islandExpanded {
                            Text(text)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 12)
                        }
                    }
                    .padding(.top, 16)
                    .animation(.spring(duration: 0.7, bounce: 0.25), value: islandExpanded)

                Spacer()

                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        if appearance == .clear {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        } else {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        }
                    }
                    .padding(.horizontal, 18)
                    .offset(y: bannerOffset)
                    .opacity(bannerOpacity)

                HStack {
                    Circle()
                        .fill(.black.opacity(0.18))
                        .frame(width: 44, height: 44)
                        .overlay { Image(systemName: "flashlight.off.fill") }
                    Spacer()
                    Circle()
                        .fill(.black.opacity(0.18))
                        .frame(width: 44, height: 44)
                        .overlay { Image(systemName: "camera.fill") }
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lock Screen preview")
        .onAppear {
            if animated {
                startAnimation()
            } else {
                bannerOffset = 0
                bannerOpacity = 1
            }
        }
    }

    private func startAnimation() {
        guard !reduceMotion else {
            bannerOffset = 0
            bannerOpacity = 1
            return
        }

        func playCycle() {
            bannerOffset = -72
            bannerOpacity = 0
            islandExpanded = false

            withAnimation(.spring(duration: 0.75, bounce: 0.28).delay(0.35)) {
                bannerOffset = 0
                bannerOpacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.spring(duration: 0.55, bounce: 0.15)) {
                    islandExpanded = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    bannerOpacity = 0
                    bannerOffset = -24
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    playCycle()
                }
            }
        }

        playCycle()
    }
}
