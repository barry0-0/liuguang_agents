import Foundation
import Testing

@testable import Liuguang

@MainActor
struct RecentProjectsForNewSessionTests {
    @Test func projectWithoutSessionsIsOfferedForNewSessionButNotListedInTheSidebar() throws {
        let isolatedUserDefaults = try IsolatedUserDefaults()
        defer { isolatedUserDefaults.removeSuite() }
        let listed = Conversation.fixture(projectPath: "/tmp/liuguang-tests/listed")
        let emptyProjectPath = ProjectLocation(host: .thisMac, path: "/tmp/liuguang-tests/empty").key
        let store = ConversationStore(
            adapters: [],
            userDefaults: isolatedUserDefaults.userDefaults,
            sessionNotifier: RecordingSessionNotifier(),
            startsBackgroundPolling: false
        )
        store.replaceConversations(on: .thisMac, with: [listed])
        store.rememberSidebarProjects([emptyProjectPath])

        let recentProjects = store.recentProjectsForNewSession
        let filtered = store.filteredSidebarProjection(
            providerFilter: .all,
            recencyFilter: .all,
            searchText: ""
        )

        #expect(recentProjects.map(\.projectPath) == [listed.projectDirectoryKey, emptyProjectPath])
        #expect(recentProjects.last?.sessionCount == 0)
        #expect(filtered.projects.map(\.projectPath) == [listed.projectDirectoryKey])
    }

    @Test func renamedEmptyProjectUsesItsSavedDisplayName() throws {
        let isolatedUserDefaults = try IsolatedUserDefaults()
        defer { isolatedUserDefaults.removeSuite() }
        let emptyProjectPath = ProjectLocation(host: .thisMac, path: "/tmp/liuguang-tests/empty").key
        let store = ConversationStore(
            adapters: [],
            userDefaults: isolatedUserDefaults.userDefaults,
            sessionNotifier: RecordingSessionNotifier(),
            startsBackgroundPolling: false
        )
        store.rememberSidebarProjects([emptyProjectPath])
        store.renameProject(emptyProjectPath, to: "Empty project")

        #expect(store.recentProjectsForNewSession.map(\.displayName) == ["Empty project"])
    }
}
