import SwiftUI

struct ProjectContextMenu: View {
    let store: ConversationStore
    let project: ProjectConversationGroup
    let onNewSession: (ConversationProvider) -> Void
    let onRename: () -> Void
    let onRemoveProjectAndDeleteSessions: () -> Void

    var body: some View {
        ProjectFolderMenuItems(
            store: store,
            location: project.location,
            projectDisplayName: project.displayName,
            onNewSession: onNewSession
        )
        Button("Rename project…", systemImage: "pencil", action: onRename)
        Button(project.isPinned ? "Unpin project" : "Pin project", systemImage: project.isPinned ? "pin.slash" : "pin") {
            store.setPinned(!project.isPinned, projectPath: project.projectPath)
        }
        Divider()
        Button(
            "Remove project…",
            systemImage: "trash",
            role: .destructive,
            action: onRemoveProjectAndDeleteSessions
        )
        .disabled(!project.location.canDeleteProjectFolder)
    }
}
