import AppKit
import SwiftUI

@MainActor
final class TerminalImageAttachments: ObservableObject {
    struct Attachment: Identifiable, Equatable {
        let id = UUID()
        let index: Int
        let image: NSImage
        let marker: String

        var label: String { marker }
    }

    @Published private(set) var items: [Attachment] = []
    @Published var preview: Attachment?
    private var nextIndex = 1
    private var removeHandler: ((Attachment) -> Bool)?

    var nextMarkerNumber: Int { nextIndex }

    func setRemoveHandler(_ handler: @escaping (Attachment) -> Bool) {
        removeHandler = handler
    }

    func add(_ image: TerminalClipboardImage, marker: String? = nil) {
        guard let nsImage = NSImage(data: image.data) else { return }
        let attachment = Attachment(index: nextIndex, image: nsImage, marker: marker ?? "Image #\(nextIndex)")
        nextIndex += 1
        items.append(attachment)
    }

    @discardableResult
    func remove(_ attachment: Attachment) -> Bool {
        var removed = true
        if let removeHandler {
            removed = removeHandler(attachment)
        }
        guard removed else { return false }
        items.removeAll { $0.id == attachment.id }
        if preview?.id == attachment.id { preview = nil }
        return true
    }

    func clear() {
        items.removeAll()
        preview = nil
        nextIndex = 1
    }
}
