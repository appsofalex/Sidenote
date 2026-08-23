import SwiftUI
import UIKit

struct CaptureTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    var font: UIFont

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
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
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.parent = self
        if view.font != font {
            view.font = font
        }
        if view.text != text && !context.coordinator.isEditing {
            view.text = text
        }
        DispatchQueue.main.async {
            if isFocused, !view.isFirstResponder {
                view.becomeFirstResponder()
            } else if !isFocused, view.isFirstResponder {
                view.resignFirstResponder()
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: CaptureTextView
        var isEditing = false

        init(_ parent: CaptureTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            if !parent.isFocused {
                parent.isFocused = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
            if parent.isFocused {
                parent.isFocused = false
            }
        }
    }
}
