import ActivityKit
import SwiftUI
import WidgetKit

@main
struct SidenoteLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        SidenoteHomeWidget()
        SidenoteLiveActivityWidget()
    }
}

struct SidenoteLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SidenoteActivityAttributes.self) { context in
            LockScreenLiveView(state: context.state)
                .widgetURL(URL(string: "sidenote://entry/\(context.attributes.entryId.uuidString)"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LiveMark(size: 10)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.text)
                        .font(SidenoteTypography.font(context.state.font, size: SidenoteTypography.liveSize(context.state.textSize)))
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                LiveMark(size: 8)
            } compactTrailing: {
                EmptyView()
            } minimal: {
                LiveMark(size: 7)
            }
            .widgetURL(URL(string: "sidenote://entry/\(context.attributes.entryId.uuidString)"))
        }
    }
}

struct LockScreenLiveView: View {
    var state: SidenoteActivityAttributes.ContentState

    var body: some View {
        Text(state.text)
            .font(SidenoteTypography.font(state.font, size: SidenoteTypography.liveSize(state.textSize)))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .activityBackgroundTint(state.appearance == .clear ? Color.clear : nil)
            .activitySystemActionForegroundColor(.secondary)
    }
}

struct LiveMark: View {
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .strokeBorder(Color.secondary, lineWidth: 1.2)
            .frame(width: size, height: size)
    }
}
