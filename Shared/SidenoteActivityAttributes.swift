import ActivityKit
import CoreGraphics
import Foundation

struct SidenoteActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var text: String
        var font: SidenoteFontChoice
        var textSize: SidenoteTextSize
        var appearance: LiveAppearance
    }

    var entryId: UUID
}

enum SidenoteFontChoice: String, Codable, CaseIterable, Identifiable, Hashable {
    case system
    case newYork
    case georgia
    case mono

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .newYork: "New York"
        case .georgia: "Georgia"
        case .mono: "Mono"
        }
    }
}

enum SidenoteTextSize: String, Codable, CaseIterable, Identifiable, Hashable {
    case small
    case regular
    case large

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .small: "Small"
        case .regular: "Default"
        case .large: "Large"
        }
    }

    var scale: CGFloat {
        switch self {
        case .small: 0.88
        case .regular: 1.0
        case .large: 1.18
        }
    }
}

enum LiveAppearance: String, Codable, CaseIterable, Identifiable, Hashable {
    case `default`
    case clear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default: "Default"
        case .clear: "Clear"
        }
    }
}

enum AppAppearance: String, Codable, CaseIterable, Identifiable, Hashable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}
