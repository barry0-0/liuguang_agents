import SwiftUI

struct SelectedProjectsContextMenu: View {
    let store: ConversationStore
    let selectedProjectIDs: Set<String>
    let onRemoveAndDeleteSessions: () -> Void
    let canDeleteFolders: Bool

    var body: some View {
        Text("\(selectedProjectIDs.count) projects selected")
        Button(
            "Remove \(selectedProjectIDs.count) projects…",
            systemImage: "trash",
            role: .destructive,
            action: onRemoveAndDeleteSessions
        )
        .disabled(!canDeleteFolders)
    }
}
