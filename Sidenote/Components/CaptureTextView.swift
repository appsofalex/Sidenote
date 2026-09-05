import SwiftUI
import UIKit

/// UITextView that hard-limits the text container width so lines always wrap
/// inside the capture column instead of running off-screen.
final class CaptureUITextView: UITextView {
    var layoutContentWidth: CGFloat = 0

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
        backgroundColor = .clear
        textAlignment = .left
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyTextContainerWidth()
        clampHorizontalOffset()
    }

    /// UITextView scrolls horizontally to keep the caret visible on long lines.
    /// That shifts the whole capture column right after the first wrap — clamp X to 0.
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        var visible = rect
        visible.origin.x = 0
        super.scrollRectToVisible(visible, animated: animated)
        clampHorizontalOffset()
    }

    func applyTextContainerWidth() {
        let viewWidth = layoutContentWidth > 0 ? layoutContentWidth : bounds.width
        guard viewWidth > 0 else { return }

        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byWordWrapping

        let horizontalInsets = textContainerInset.left + textContainerInset.right
        let containerWidth = max(0, viewWidth - horizontalInsets)
        let targetSize = CGSize(width: containerWidth, height: .greatestFiniteMagnitude)

        if abs(textContainer.size.width - containerWidth) > 0.5 {
            textContainer.size = targetSize
            layoutManager.ensureLayout(for: textContainer)
            invalidateIntrinsicContentSize()
        }
    }

    func measuredTextHeight() -> CGFloat {
        applyTextContainerWidth()
        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        return max(usedRect.height, font?.lineHeight ?? 0)
    }

    func clampHorizontalOffset() {
        guard contentOffset.x != 0 else { return }
        setContentOffset(CGPoint(x: 0, y: contentOffset.y), animated: false)
    }
}

struct CaptureTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var measuredContentHeight: CGFloat
    var contentTopInset: CGFloat
    var font: UIFont
    var textWidth: CGFloat
    var acceptsTouches: Bool = true
    var allowsFocus: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> CaptureUITextView {
        let view = CaptureUITextView()
        view.delegate = context.coordinator
        view.textContainerInset = UIEdgeInsets(top: contentTopInset, left: 0, bottom: 24, right: 0)
        view.keyboardDismissMode = .interactive
        view.adjustsFontForContentSizeCategory = true
        view.tintColor = .label
        view.textColor = .label
        view.font = font
        view.text = text
        view.allowsEditingTextAttributes = false
        view.isScrollEnabled = true
        view.textContentType = .none
        view.smartDashesType = .yes
        view.smartQuotesType = .yes
        view.autocorrectionType = .yes
        view.layoutContentWidth = textWidth
        return view
    }

    func updateUIView(_ view: CaptureUITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self

        view.layoutContentWidth = textWidth

        if view.font != font {
            view.font = font
        }
        if view.text != text, text.isEmpty || !coordinator.isEditing {
            view.text = text
        }

        view.isUserInteractionEnabled = acceptsTouches

        let inset = UIEdgeInsets(top: contentTopInset, left: 0, bottom: 24, right: 0)
        if view.textContainerInset != inset {
            view.textContainerInset = inset
        }

        view.applyTextContainerWidth()
        coordinator.reportContentHeight(from: view)
        view.clampHorizontalOffset()

        if isFocused, allowsFocus {
            coordinator.isDismissLocked = false
            if !view.isFirstResponder {
                DispatchQueue.main.async {
                    guard coordinator.parent.isFocused,
                          coordinator.parent.allowsFocus,
                          !coordinator.isDismissLocked,
                          !view.isFirstResponder else { return }
                    view.becomeFirstResponder()
                    view.applyTextContainerWidth()
                    coordinator.reportContentHeight(from: view)
                }
            }
        } else {
            coordinator.isDismissLocked = true
            coordinator.isEditing = false
            if view.isFirstResponder {
                view.resignFirstResponder()
            }
            if text.isEmpty, !view.text.isEmpty {
                view.text = ""
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: CaptureTextView
        var isEditing = false
        var isDismissLocked = false

        init(_ parent: CaptureTextView) {
            self.parent = parent
        }

        func reportContentHeight(from textView: CaptureUITextView) {
            let height = textView.measuredTextHeight()
            guard abs(parent.measuredContentHeight - height) > 0.5 else { return }
            DispatchQueue.main.async {
                self.parent.measuredContentHeight = height
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            guard let textView = textView as? CaptureUITextView else { return }
            parent.text = textView.text
            textView.applyTextContainerWidth()
            reportContentHeight(from: textView)
            textView.clampHorizontalOffset()
        }

        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            !isDismissLocked && (parent.allowsFocus || parent.isFocused)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            guard let textView = textView as? CaptureUITextView else { return }
            guard !isDismissLocked, parent.allowsFocus || parent.isFocused else {
                textView.resignFirstResponder()
                return
            }
            isEditing = true
            if !parent.isFocused {
                parent.isFocused = true
            }
            textView.applyTextContainerWidth()
            reportContentHeight(from: textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let textView = textView as? CaptureUITextView else { return }
            textView.clampHorizontalOffset()
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
            if parent.text.isEmpty, !textView.text.isEmpty {
                textView.text = ""
            }
        }
    }
}
