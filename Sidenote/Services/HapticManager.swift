import UIKit

enum HapticManager {
    static func commit() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.85)
    }

    static func remove() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
    }

    static func restore() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
    }

    static func permanentDelete() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func goLive() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
    }

    static func stopLive() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
    }
}
