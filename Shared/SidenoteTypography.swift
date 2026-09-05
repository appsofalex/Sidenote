import SwiftUI
import UIKit

enum SidenoteTypography {
    static func font(
        _ choice: SidenoteFontChoice,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        switch choice {
        case .system:
            .system(size: size, weight: weight, design: .default)
        case .mono:
            .system(size: size, weight: weight, design: .monospaced)
        case .serif:
            .system(size: size, weight: weight, design: .serif)
        }
    }

    static func uiFont(
        _ choice: SidenoteFontChoice,
        size: CGFloat,
        weight: UIFont.Weight = .regular
    ) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let design: UIFontDescriptor.SystemDesign = switch choice {
        case .system: .default
        case .mono: .monospaced
        case .serif: .serif
        }
        guard let descriptor = base.fontDescriptor.withDesign(design) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }

    static func captureSize(_ textSize: SidenoteTextSize) -> CGFloat {
        22 * textSize.scale
    }

    static func streamSize(_ textSize: SidenoteTextSize) -> CGFloat {
        17 * textSize.scale
    }

    static func liveSize(_ textSize: SidenoteTextSize) -> CGFloat {
        16 * textSize.scale
    }

    static func timestampSize(_ textSize: SidenoteTextSize) -> CGFloat {
        13 * textSize.scale
    }
}
