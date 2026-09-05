import Observation
import SwiftUI
import UIKit

@Observable
final class SidenoteSettings {
    var appearance: AppAppearance {
        didSet { AppGroup.defaults.set(appearance.rawValue, forKey: SettingsKey.appearance) }
    }

    var font: SidenoteFontChoice {
        didSet { AppGroup.defaults.set(font.rawValue, forKey: SettingsKey.font) }
    }

    var textSize: SidenoteTextSize {
        didSet { AppGroup.defaults.set(textSize.rawValue, forKey: SettingsKey.textSize) }
    }

    var liveAppearance: LiveAppearance {
        didSet { AppGroup.defaults.set(liveAppearance.rawValue, forKey: SettingsKey.liveAppearance) }
    }

    init() {
        let defaults = AppGroup.defaults
        appearance = AppAppearance(rawValue: defaults.string(forKey: SettingsKey.appearance) ?? "") ?? .light
        font = SidenoteFontChoice.resolved(defaults.string(forKey: SettingsKey.font))
        textSize = SidenoteTextSize(rawValue: defaults.string(forKey: SettingsKey.textSize) ?? "") ?? .regular
        liveAppearance = LiveAppearance(rawValue: defaults.string(forKey: SettingsKey.liveAppearance) ?? "") ?? .default
    }

    var captureFont: Font {
        SidenoteTypography.font(font, size: SidenoteTypography.captureSize(textSize))
    }

    var streamFont: Font {
        SidenoteTypography.font(font, size: SidenoteTypography.streamSize(textSize))
    }

    var liveFont: Font {
        SidenoteTypography.font(font, size: SidenoteTypography.liveSize(textSize))
    }

    var timestampFont: Font {
        .system(size: SidenoteTypography.timestampSize(textSize), weight: .regular)
    }

    var headingFont: Font {
        .system(size: 12 * textSize.scale, weight: .semibold)
    }

    var captureUIFont: UIFont {
        let size = SidenoteTypography.captureSize(textSize)
        let font = SidenoteTypography.uiFont(self.font, size: size)
        return UIFontMetrics(forTextStyle: .title2).scaledFont(for: font)
    }
}

extension AppAppearance {
    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
}
