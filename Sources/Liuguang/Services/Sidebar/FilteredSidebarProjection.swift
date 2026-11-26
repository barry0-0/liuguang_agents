import Foundation

struct FilteredSidebarProjection {
    struct Inputs: Equatable {
        let projectionInputs: SidebarProjection.Inputs
        let titleAliases: ConversationTitleAliases
        let providerFilter: ConversationProviderFilter
        let recencyFilter: SessionRecencyFilter
        let statusFilter: SessionStatusFilter
        let archiveFilter: SessionArchiveFilter
        let archived: ArchivedSessions
        let running: SessionsRunning
        let waiting: SessionsWaitingForYou
        let searchText: String
        let messageMatchConversationIDs: Set<String>
        let recencyNowToTheMinute: Date

        static func roundedDownToTheMinuteSoRendersReuseTheCache(_ now: Date) -> Date {
            Date(timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate / 60).rounded(.down) * 60)
        }
    }

    let inputs: Inputs
    let projects: [ProjectConversationGroup]
    let listedConversationIDs: Set<String>
    let allSessionCount: Int
    let archivedSessionCount: Int
    let recentSessionCount: Int
    let runningSessionCount: Int
    let waitingSessionCount: Int

    init(inputs: Inputs, projection: SidebarProjection, title: (Conversation) -> String) {
        self.inputs = inputs
        let originallyEmptyProjectPaths = Set(
            projection.projectGroups
                .filter { $0.conversations.isEmpty && $0.pendingNewSessions.isEmpty }
                .map(\.projectPath)
        )
        let meaningfulConversations = projection.conversations.filter { conversation in
            let trimmedTitle = title(conversation).trimmingCharacters(in: .whitespacesAndNewlines)
            let titleIsNumeric = !trimmedTitle.isEmpty && trimmedTitle.allSatisfy(\.isNumber)
            let titleIsNumericPrefix = trimmedTitle.split(separator: ":", maxSplits: 1).first.map { !$0.isEmpty && $0.allSatisfy(\.isNumber) } ?? false
            guard trimmedTitle.isEmpty || titleIsNumeric || titleIsNumericPrefix || trimmedTitle == ConversationMetadata.untitledConversationTitle else { return true }
            return !inputs.messageMatchConversationIDs.contains(conversation.id)
        }
        let toolConversations = meaningfulConversations.filter { inputs.providerFilter.includes($0.provider) }
        archivedSessionCount = toolConversations.filter { inputs.archived.isArchived(conversationID: $0.id) }.count
        let countedConversations = toolConversations.filter { inputs.archiveFilter.includes($0, archived: inputs.archived) }
        allSessionCount = countedConversations.count
        recentSessionCount =
            countedConversations
            .filter { SessionRecencyFilter.recent.includes($0, now: inputs.recencyNowToTheMinute) }
            .count
        runningSessionCount = countedConversations.filter { inputs.running.conversationIDs.contains($0.id) }.count
        waitingSessionCount = countedConversations.filter { inputs.waiting.conversationIDs.contains($0.id) }.count
        let filteredProjects = SidebarProjectFiltering.projects(
            projection.projectGroups,
            providerFilter: inputs.providerFilter,
            recencyFilter: inputs.recencyFilter,
            statusFilter: inputs.statusFilter,
            archiveFilter: inputs.archiveFilter,
            archived: inputs.archived,
            running: inputs.running,
            waiting: inputs.waiting,
            now: inputs.recencyNowToTheMinute
        )
        let visibleProjects = filteredProjects.compactMap { project -> ProjectConversationGroup? in
            let conversations = project.conversations.filter { conversation in
                guard meaningfulConversations.contains(where: { $0.id == conversation.id }) else { return false }
                return true
            }
            let pending = project.pendingNewSessions.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            let isListedEmptyProject = originallyEmptyProjectPaths.contains(project.projectPath)
                && inputs.projectionInputs.sidebarProjectList.projectPaths.contains(project.projectPath)
            guard !conversations.isEmpty || !pending.isEmpty || isListedEmptyProject else { return nil }
            return ProjectConversationGroup(
                projectPath: project.projectPath,
                displayName: project.displayName,
                pinnedPlace: project.pinnedPlace,
                conversations: conversations,
                pendingNewSessions: pending
            )
        }
        projects = SidebarProjectFiltering.projects(
            visibleProjects,
            matching: inputs.searchText,
            title: title,
            messageMatchConversationIDs: inputs.messageMatchConversationIDs
        )
        listedConversationIDs = Set(projects.lazy.flatMap(\.conversations).map(\.id))
    }
}
