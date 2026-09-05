import LinkPresentation
import SwiftUI
import UIKit

struct CircleIconButton<Label: View>: View {
    var action: () -> Void
    var accessibilityLabel: String
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// System-standard sheet close control on iOS 26+; circular fallback on earlier versions.
struct CloseToolbarButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if #available(iOS 26, *) {
                Button(role: .close, action: action)
            } else {
                CircleIconButton(action: action, accessibilityLabel: "Close") {
                    Image(systemName: "xmark")
                }
            }
        }
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

private final class ShareTextItem: NSObject, UIActivityItemSource {
    let text: String
    let title: String

    init(text: String, title: String) {
        self.text = text
        self.title = title
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        text
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any {
        text
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        if let icon = UIImage(named: "ShareIcon") {
            metadata.iconProvider = NSItemProvider(object: icon)
        }
        return metadata
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var title: String = "Sidenote"

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityItems = items.map { item -> Any in
            if let text = item as? String {
                ShareTextItem(text: text, title: title)
            } else {
                item
            }
        }
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

extension View {
    /// Native circular Liquid Glass chrome on iOS 26+; circular fallback otherwise.
    @ViewBuilder
    func sidenoteGlassChrome() -> some View {
        if #available(iOS 26, *) {
            self
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            self
        }
    }
}
