import SwiftUI

@main
enum LiuguangMain {
    static func main() {
        if let exitStatus = SSHAskpassRelay.exitStatusIfStartedAsAskpass() { exit(exitStatus) }
        LiuguangApp.main()
    }
}

struct LiuguangApp: App {
    @StateObject private var languageStore = AppLanguageStore.shared
    @StateObject private var workspaceReads = WorkspaceReadService()
    // periphery:ignore - SwiftUI reads the adaptor to install the delegate.
    @NSApplicationDelegateAdaptor(LiuguangAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup(id: "workspace") {
            ContentView(readService: workspaceReads)
                .handsOverWindowOpening()
                .appTheme(from: .shared)
                .appLanguage(from: languageStore)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 720)
        .commands {
            WorkspaceNavigationCommands()
            TranscriptBookmarkCommands()
            WorkspaceTabCommands()
            SidebarToggleCommands()
            ConversationMapCommands()
            TextZoomCommands()
            AppWideSheetCommands()
        }
    }
}
