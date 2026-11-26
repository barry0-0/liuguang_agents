import Foundation

enum SessionDeletionRequest {
    case conversation(Conversation)
    case conversations([Conversation])
    case project(String)
    case projectFolderDeletion(String)
    case selectedProjectFolderDeletion(Set<String>)
}
