import Foundation
import SwiftUI

/// Renders note text with bold (`**…**`) and auto-detected tappable blue links.
struct LinkifiedText: View {
    let text: String
    var font: Font = .body
    var linkify: Bool = true

    var body: some View {
        Text(NoteMarkup.attributedString(text, linkify: linkify))
            .font(font)
            .tint(.blue)
            .textSelection(.enabled)
    }
}
