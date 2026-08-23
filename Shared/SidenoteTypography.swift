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
        case .newYork:
            .system(size: size, weight: weight, design: .serif)
        case .georgia:
            .custom("Georgia", size: size).weight(weight)
        case .mono:
            .system(size: size, weight: weight, design: .monospaced)
        }
    }

    static func uiFont(
        _ choice: SidenoteFontChoice,
        size: CGFloat,
        weight: UIFont.Weight = .regular
    ) -> UIFont {
        switch choice {
        case .system:
            return .systemFont(ofSize: size, weight: weight)
        case .newYork:
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            guard let descriptor = base.fontDescriptor.withDesign(.serif) else { return base }
            return UIFont(descriptor: descriptor, size: size)
        case .georgia:
            let traits: UIFontDescriptor.SymbolicTraits = weight == .regular ? [] : .traitBold
            if let font = UIFont(name: "Georgia", size: size) {
                if traits.isEmpty { return font }
                if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    return UIFont(descriptor: descriptor, size: size)
                }
                return font
            }
            return .systemFont(ofSize: size, weight: weight)
        case .mono:
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            guard let descriptor = base.fontDescriptor.withDesign(.monospaced) else { return base }
            return UIFont(descriptor: descriptor, size: size)
        }
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
