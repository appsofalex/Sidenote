import SwiftUI

struct CircleIconButton<Label: View>: View {
    var action: () -> Void
    var accessibilityLabel: String
    @ViewBuilder var label: () -> Label
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            label()
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: Circle())
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.08),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct CircleIconVisual: View {
    var systemName: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.primary)
            .frame(width: 40, height: 40)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: Circle())
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.08),
                radius: 12,
                x: 0,
                y: 4
            )
    }
}

struct DoneButton: View {
    var title: String = "Done"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primary, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct LiveMark: View {
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .strokeBorder(Color.secondary, lineWidth: 1.2)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
