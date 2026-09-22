import Foundation
import SwiftUI
import UIKit

/// Lightweight note markup: `**bold**` in the stored string, rendered without markers.
enum NoteMarkup {
    static func plainText(_ markdown: String) -> String {
        markdown.replacingOccurrences(of: "**", with: "")
    }

    static func isFullyBold(_ markdown: String) -> Bool {
        let attributed = attributedString(markdown, linkify: false)
        guard !attributed.characters.isEmpty else { return false }
        for run in attributed.runs {
            if run.inlinePresentationIntent?.contains(.stronglyEmphasized) != true {
                return false
            }
        }
        return true
    }

    static func toggleFullyBold(_ markdown: String) -> String {
        let plain = plainText(markdown)
        guard !plain.isEmpty else { return markdown }
        if isFullyBold(markdown) {
            return plain
        }
        return "**\(plain)**"
    }

    static func attributedString(_ markdown: String, linkify: Bool = true) -> AttributedString {
        var attributed = AttributedString()
        var isBold = false
        var index = markdown.startIndex

        while index < markdown.endIndex {
            if markdown[index...].hasPrefix("**") {
                isBold.toggle()
                index = markdown.index(index, offsetBy: 2)
                continue
            }

            var character = AttributedString(String(markdown[index]))
            if isBold {
                character.inlinePresentationIntent = .stronglyEmphasized
            }
            attributed.append(character)
            index = markdown.index(after: index)
        }

        if linkify {
            applyLinks(to: &attributed)
        }

        return attributed
    }

    static func nsAttributedString(_ markdown: String, font: UIFont) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let boldFont = font.sidenoteBold()
        let color = UIColor.label
        var isBold = false
        var index = markdown.startIndex

        while index < markdown.endIndex {
            if markdown[index...].hasPrefix("**") {
                isBold.toggle()
                index = markdown.index(index, offsetBy: 2)
                continue
            }

            let attributes: [NSAttributedString.Key: Any] = [
                .font: isBold ? boldFont : font,
                .foregroundColor: color
            ]
            result.append(NSAttributedString(string: String(markdown[index]), attributes: attributes))
            index = markdown.index(after: index)
        }

        if result.length == 0 {
            return NSAttributedString(
                string: "",
                attributes: [
                    .font: font,
                    .foregroundColor: color
                ]
            )
        }

        return result
    }

    static func markdown(from attributed: NSAttributedString) -> String {
        guard attributed.length > 0 else { return "" }

        var result = ""
        var isBoldOpen = false
        let fullRange = NSRange(location: 0, length: attributed.length)

        attributed.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            let font = attributes[.font] as? UIFont
            let isBold = font?.sidenoteIsBold == true
            let chunk = (attributed.string as NSString).substring(with: range)
                .replacingOccurrences(of: "**", with: "")

            if isBold && !isBoldOpen {
                result += "**"
                isBoldOpen = true
            } else if !isBold && isBoldOpen {
                result += "**"
                isBoldOpen = false
            }

            result += chunk
        }

        if isBoldOpen {
            result += "**"
        }

        return result
    }

    static func typingAttributes(font: UIFont, bold: Bool = false) -> [NSAttributedString.Key: Any] {
        [
            .font: bold ? font.sidenoteBold() : font,
            .foregroundColor: UIColor.label
        ]
    }

    private static func applyLinks(to attributed: inout AttributedString) {
        let plain = String(attributed.characters)
        guard !plain.isEmpty,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else { return }

        let nsRange = NSRange(plain.startIndex..<plain.endIndex, in: plain)
        for match in detector.matches(in: plain, options: [], range: nsRange) {
            guard let url = match.url,
                  let stringRange = Range(match.range, in: plain),
                  let attributedRange = Range(stringRange, in: attributed)
            else { continue }

            attributed[attributedRange].link = url
            attributed[attributedRange].foregroundColor = .blue
        }
    }
}

extension UIFont {
    var sidenoteIsBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    func sidenoteBold() -> UIFont {
        let traits = fontDescriptor.symbolicTraits.union(.traitBold)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }

    func sidenoteRegular() -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitBold)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }

    func sidenoteByPreservingWeight(of other: UIFont) -> UIFont {
        other.sidenoteIsBold ? sidenoteBold() : sidenoteRegular()
    }
}
