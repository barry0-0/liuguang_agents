import Testing

@testable import Liuguang

struct SessionDeletionLocalizationTests {
    private let chinese = AppInterfaceLanguage(identifier: "zh-Hans")

    @Test func destructiveRemoteWarningPreservesDestinationAndExplainsPermanence() {
        let conversation = Conversation.fixture(provider: .pi, host: .ssh("me@build"))
        #expect(
            SessionDeletionConfirmationText.message(forDeleting: conversation, language: chinese)
                == "me@build 上的 Pi 会话文件及其关联文件夹将被永久删除。SSH 主机没有废纸篓，此操作无法撤销。")
    }

    @Test func skippedCountsAndDeletionCountAreTranslatedAsCompleteSentences() {
        let plan = SessionDeletionPlan(deletableConversations: [.fixture(), .fixture()], openTerminalCount: 2)
        #expect(SessionDeletionConfirmationText.buttonTitle(for: plan, language: chinese) == "删除 2 个会话")
        #expect(
            SessionDeletionConfirmationText.skippedSessionsSentence(for: plan, language: chinese)
                == "将跳过 2 个终端已打开的会话。")
    }

    @Test func subagentCountsAreTranslatedAsCompleteSentences() {
        let plan = SessionDeletionPlan(
            deletableConversations: [.fixture()], openTerminalCount: 0, deletedSubagentCount: 118, keptSubagentCount: 2
        )
        #expect(
            SessionDeletionConfirmationText.subagentSentences(for: plan, language: chinese)
                == ["同时会删除 118 个子代理会话。", "2 个子代理会话将保留在磁盘上。"])
    }

    @Test func projectFolderDeletionIsTranslatedAsOneAction() {
        let plan = SessionDeletionPlan(deletableConversations: [.fixture(), .fixture()], openTerminalCount: 0)
        #expect(
            SessionDeletionConfirmationText.projectRemovalButtonTitle(for: plan, language: chinese)
                == "移除项目并删除 2 个会话")
        #expect(
            SessionDeletionConfirmationText.message(
                forDeletingProjectAt: ProjectLocation(host: .thisMac, path: "/Users/me/app"),
                plan: plan,
                deletingProjectFolder: true,
                language: chinese
            ) == "此操作会影响 /Users/me/app 中所有工具的会话，包括当前筛选隐藏的会话。流光中的项目会被移除，各 CLI 保存的会话会被删除，磁盘上的项目文件夹不会改变。仍在运行的会话会先结束。")
        #expect(
            SessionDeletionConfirmationText.selectedProjectsRemovalButtonTitle(projectCount: 2, plan: plan, language: chinese)
                == "删除 2 个项目文件夹和 2 个会话")
    }
}
