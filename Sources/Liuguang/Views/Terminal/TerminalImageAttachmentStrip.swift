import SwiftUI

struct TerminalImageAttachmentStrip: View {
    @ObservedObject var attachments: TerminalImageAttachments

    var body: some View {
        EmptyView()
            .sheet(item: $attachments.preview) { attachment in
                VStack(spacing: 12) {
                    Image(nsImage: attachment.image)
                        .resizable()
                        .scaledToFit()
                    HStack {
                        Button("移除") { attachments.remove(attachment) }
                        Button("完成") { attachments.preview = nil }
                            .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(20)
                .frame(minWidth: 480, minHeight: 360)
                .background(ThemePalette.contentSurface)
            }
    }
}
