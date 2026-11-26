import AppKit

/// A CLI on this Mac reads the image off the clipboard itself once it gets an empty paste, as Claude Code does. A
/// SwiftTerm tab's own paste sends one; a Ghostty tab sends it itself, since Ghostty drops an empty paste.
@MainActor
final class TerminalImagePaste {
    enum Handling: Equatable {
        case sendEmptyPaste
        case sendNothing
    }

    var pasteboard = NSPasteboard.general
    var copyToHost: ((TerminalClipboardImage) -> Void)?
    var onImagePasted: ((TerminalClipboardImage) -> Void)?

    var clipboardHoldsOnlyAnImage: Bool { TerminalClipboardImage.isOnly(on: pasteboard) }

    func handleClipboardImage() -> Handling? {
        guard clipboardHoldsOnlyAnImage else { return nil }
        guard let image = TerminalClipboardImage(pasteboard: pasteboard) else { return nil }
        onImagePasted?(image)
        return .sendEmptyPaste
    }

    func copyImageToHostIfNeeded(_ image: TerminalClipboardImage) {
        guard let copyToHost else { return }
        copyToHost(image)
    }
}
