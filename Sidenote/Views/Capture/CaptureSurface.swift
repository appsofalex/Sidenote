import SwiftUI

struct CaptureSurface: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    var droppingText: String?
    var dropProgress: CGFloat
    var showEarlierCue: Bool
    var font: Font
    var uiFont: UIFont

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty && droppingText == nil {
                    Text("Start typing...")
                        .font(font)
                        .foregroundStyle(.tertiary)
                        .allowsHitTesting(false)
                }

                CaptureTextView(text: $text, isFocused: $isFocused, font: uiFont)
                    .opacity(droppingText == nil ? 1 : 0)
                    .accessibilityLabel("Sidenote")
                    .accessibilityHint("Writes a thought into Sidenote.")

                if let droppingText {
                    Text(droppingText)
                        .font(font)
                        .foregroundStyle(.primary)
                        .offset(y: dropProgress * 220)
                        .opacity(1 - dropProgress)
                        .blur(radius: dropProgress * 1.5)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)

            Spacer(minLength: 12)

            if showEarlierCue {
                VStack(spacing: 6) {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 15, weight: .semibold))
                    Text("earlier")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(0.8)
                }
                .foregroundStyle(.quaternary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)
                .accessibilityHidden(true)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }
}
