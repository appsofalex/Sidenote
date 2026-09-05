import SwiftUI

struct CaptureSurface: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    var droppingText: String?
    var dropProgress: CGFloat
    var isPromptVisible: Bool = true
    var canActivate: Bool = true
    /// When true (notes fully hidden at home), taps above/below the prompt also start typing.
    var allowsExpandedTap: Bool = false
    var onActivate: (() -> Void)? = nil
    var font: Font
    var uiFont: UIFont

    @State private var measuredContentHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let lineHeight = uiFont.lineHeight
            let screenMidY = UIScreen.main.bounds.midY
            let localTop = geo.frame(in: .global).minY
            let blockHeight = max(measuredContentHeight, lineHeight)
            let contentTopInset = max(0, screenMidY - localTop - (blockHeight / 2))
            let promptBandHeight = max(lineHeight + 16, 52)
            let showPrompt = isPromptVisible && text.isEmpty && droppingText == nil && !isFocused
            let showExpandedTap = allowsExpandedTap && canActivate && showPrompt

            ZStack(alignment: .topLeading) {
                CaptureTextView(
                    text: $text,
                    isFocused: $isFocused,
                    measuredContentHeight: $measuredContentHeight,
                    contentTopInset: contentTopInset,
                    font: uiFont,
                    textWidth: geo.size.width,
                    acceptsTouches: isFocused,
                    allowsFocus: canActivate || isFocused
                )
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .clipped()
                .opacity(isPromptVisible && droppingText == nil ? 1 : 0)
                .allowsHitTesting(isFocused)
                .accessibilityLabel("Sidenote")
                .accessibilityHint("Writes a thought into Sidenote.")

                if showExpandedTap {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: max(0, contentTopInset))
                            .contentShape(Rectangle())
                            .onTapGesture(perform: activateCapture)

                        Color.clear
                            .frame(height: promptBandHeight)
                            .accessibilityHidden(true)

                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: activateCapture)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }

                if isPromptVisible, text.isEmpty, droppingText == nil {
                    Button(action: activateCapture) {
                        Text("Start typing...")
                            .font(font)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .offset(y: contentTopInset)
                    .disabled(!canActivate)
                    .allowsHitTesting(canActivate && !isFocused)
                    .transition(.opacity)
                }

                if isPromptVisible, let droppingText {
                    Text(droppingText)
                        .font(font)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: contentTopInset + dropProgress * max(220, geo.size.height * 0.45))
                        .opacity(1 - dropProgress)
                        .blur(radius: dropProgress * 1.5)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .animation(.easeInOut(duration: 0.2), value: isPromptVisible)
            .onChange(of: text) { _, newValue in
                if newValue.isEmpty {
                    measuredContentHeight = 0
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private func activateCapture() {
        onActivate?()
        isFocused = true
    }
}
