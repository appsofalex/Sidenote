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
    case mono
    case serif

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "Default"
        case .mono: "Mono"
        case .serif: "Serif"
        }
    }

    /// Maps persisted / decoded values, including legacy font names.
    static func resolved(_ raw: String?) -> SidenoteFontChoice {
        switch raw {
        case "mono": .mono
        case "serif", "newYork", "georgia": .serif
        default: .system
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Self.resolved(try container.decode(String.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
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
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}
