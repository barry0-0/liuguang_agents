import AppKit
import SwiftUI

@MainActor
final class TerminalImagePreviewPanel {
    static let shared = TerminalImagePreviewPanel()

    private var panel: NSPanel?

    func show(_ image: NSImage) {
        close()
        let view = TerminalImagePreviewView(image: image) { [weak self] in self?.close() }
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 560),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .floating
        panel.hasShadow = true
        panel.contentViewController = NSHostingController(rootView: view)
        panel.contentViewController?.view.frame = panel.contentRect(forFrameRect: panel.frame)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    func close() {
        panel?.orderOut(nil)
        panel = nil
    }
}

private struct TerminalImagePreviewView: View {
    let image: NSImage
    let onClose: () -> Void

    var body: some View {
        ZStack {
            VisualEffectBlur()
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .padding(24)
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: onClose)
        }
        .onExitCommand(perform: onClose)
    }
}

private struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
