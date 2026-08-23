import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SidenoteSettings.self) private var settings
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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

                        Divider().padding(.leading, 44)

                        NavigationLink {
                            TextSettingsView()
                        } label: {
                            SettingsRow(systemImage: "textformat", title: "Text") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

                    SettingsCard {
                        NavigationLink {
                            LiveActivitySettingsView()
                        } label: {
                            SettingsRow(systemImage: "iphone", title: "Live Activity") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

                    SettingsCard {
                        Button {
                            requestReview()
                        } label: {
                            SettingsRow(systemImage: "star", title: "Rate Sidenote") {
                                EmptyView()
                            }
                        }

                        Divider().padding(.leading, 44)

                        NavigationLink {
                            PrivacyView()
                        } label: {
                            SettingsRow(systemImage: "hand.raised", title: "Privacy") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

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
                        Text(versionString)
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CircleIconButton(action: { dismiss() }, accessibilityLabel: "Close") {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}

struct TextSettingsView: View {
    @Environment(SidenoteSettings.self) private var settings

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
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

                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Size")
                        Picker("Size", selection: Bindable(settings).textSize) {
                            ForEach(SidenoteTextSize.allCases) { size in
                                Text(size.displayName).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }

                Text("Text size is used in the app and on Live Activities. The preview is not exact.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Text")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LiveActivitySettingsView: View {
    @Environment(SidenoteSettings.self) private var settings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LiveActivityPreview(
                    text: "Collect my parcel from the post office after lunch.",
                    appearance: settings.liveAppearance
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Activity")
                        .font(.headline)
                    Text("After you go live, a sidenote can appear on the Lock Screen and in the Dynamic Island on supported iPhones. It can remain active for up to 8 hours.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                                .padding(.vertical, 14)
                            }
                            if index < LiveAppearance.allCases.count - 1 {
                                Divider().padding(.leading, 16)
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

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sidenote keeps your thoughts on this iPhone. There is no account, and nothing is sent to a server.")
                Text("Removed sidenotes stay on device for 30 days, then they are deleted.")
                Text("If you go live, the current thought is shown by iOS on the Lock Screen and Dynamic Island until you stop it or it expires.")
            }
            .font(.body)
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
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
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

struct SettingsRow<Trailing: View>: View {
    var systemImage: String?
    var title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.body)
                    .frame(width: 28)
            }
            Text(title)
            Spacer()
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct LiveActivityPreview: View {
    var text: String
    var appearance: LiveAppearance

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemFill))
                .frame(height: 280)

            VStack {
                Spacer()
                Text(text)
                    .font(.body)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.horizontal, 18)
                    .opacity(appearance == .clear ? 0.92 : 1)

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
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lock Screen preview")
    }
}
