import Foundation

@testable import Liuguang

extension Conversation {
    static func fixture(
        provider: ConversationProvider = .claude,
        sessionID: String = UUID().uuidString.lowercased(),
        projectPath: String = "/tmp/liuguang-tests/project",
        title: String = "Session",
        updatedAt: Date = .now,
        sourceFile: URL? = nil,
        host: SessionHost = .thisMac,
        parentSessionID: String? = nil
    ) -> Conversation {
        Conversation(
            provider: provider,
            sessionID: sessionID,
            projectPath: projectPath,
            suggestedTitle: title,
            updatedAt: updatedAt,
            sourceFile: sourceFile ?? URL(fileURLWithPath: "/tmp/liuguang-tests/\(sessionID).jsonl"),
            host: host,
            parentSessionID: parentSessionID
        )
    }
}
