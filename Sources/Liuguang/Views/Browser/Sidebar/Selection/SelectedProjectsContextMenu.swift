import SwiftUI

struct SelectedProjectsContextMenu: View {
    let store: ConversationStore
    let selectedProjectIDs: Set<String>
    let onRemoveAndDeleteSessions: () -> Void
    let canDeleteFolders: Bool

    var body: some View {
        Text("\(selectedProjectIDs.count) projects selected")
        Button(
            "Delete \(selectedProjectIDs.count) project folders…",
            systemImage: "trash",
            role: .destructive,
            action: onRemoveAndDeleteSessions
        )
        .disabled(!canDeleteFolders)
    }
}
