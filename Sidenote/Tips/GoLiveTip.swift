import TipKit

enum FirstUseTips {
    @Parameter
    static var hasCreatedNote: Bool = false
}

/// First-use tip: swipe up from the capture home screen to see earlier notes.
struct ScrollUpTip: Tip {
    var title: Text {
        Text("Earlier thoughts live below")
    }

    var message: Text? {
        Text("Swipe up to scroll through previous sidenotes.")
    }

    var image: Image? {
        Image(systemName: "chevron.up")
    }

    var rules: [Rule] {
        #Rule(FirstUseTips.$hasCreatedNote) { $0 == true }
    }

    var options: [any TipOption] {
        [
            MaxDisplayCount(1),
        ]
    }
}

/// First-use tip so Go Live / Live Activities are discoverable for users and App Review.
struct GoLiveTip: Tip {
    var title: Text {
        Text("Keep a thought nearby")
    }

    var message: Text? {
        Text("Long-press any sidenote, then tap Go Live. It appears on the Lock Screen and Dynamic Island.")
    }

    var image: Image? {
        Image(systemName: "record.circle")
    }

    var rules: [Rule] {
        #Rule(FirstUseTips.$hasCreatedNote) { $0 == true }
    }

    var options: [any TipOption] {
        [
            MaxDisplayCount(1),
        ]
    }
}
