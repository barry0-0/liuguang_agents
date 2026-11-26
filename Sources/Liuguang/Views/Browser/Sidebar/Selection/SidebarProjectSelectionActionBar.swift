import SwiftUI

struct SidebarProjectSelectionActionBar: View {
    let selectedCount: Int
    let onRemoveAndDeleteSessions: () -> Void
    let canDeleteFolders: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text("\(selectedCount) projects selected")
                    .font(ThemeFont.callout.weight(.medium))
                    .lineLimit(1)
                Spacer(minLength: 4)
            }
            Button(role: .destructive, action: onRemoveAndDeleteSessions) {
                Label("Delete project folders…", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(QuietBorderedButtonStyle())
            .controlSize(.small)
            .help("Move the selected project folders on this Mac to the Trash, ending sessions that still run first")
            .accessibilityLabel("Delete selected project folders")
            .disabled(!canDeleteFolders)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(ThemePalette.hoverFill)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(selectedCount) projects selected")
    }
}
