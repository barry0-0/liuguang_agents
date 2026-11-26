import Foundation

/// Reads how much of its context window each CLI's session fills, from the files the CLI writes itself.
///
/// Every CLI records its last request's token counts in its own format, and only Codex records the size of its
/// window beside them. The others get their window from the CLI's own configuration, as
/// `ContextWindowLookup` reads it.
enum ContextUsageReader {
    static func read(conversation: Conversation?) -> ContextUsage? {
        guard let conversation else { return nil }
        switch conversation.provider {
        case .codex:
            return CodexContextUsage.read(file: conversation.sourceFile)
        case .claude:
            return ClaudeContextUsage.read(file: conversation.sourceFile)
                .flatMap { usage in
                    ContextUsage(
                        used: usage.used,
                        window: ContextWindowLookup.claudeWindow(conversation: conversation),
                        reportedPercent: usage.reportedPercent
                    )
                }
        case .pi:
            return PiContextUsage.read(file: conversation.sourceFile)
                .flatMap { usage in
                    ContextUsage(
                        used: usage.used,
                        window: ContextWindowLookup.piWindow(conversation: conversation),
                        reportedPercent: usage.reportedPercent
                    )
                }
        case .opencode:
            guard
                let reply = OpenCodeContextUsage.readReply(
                    databaseFile: conversation.sourceFile,
                    sessionID: conversation.sessionID
                )
            else { return nil }
            return ContextUsage(
                used: reply.usage.used,
                window: ContextWindowLookup.openCodeWindow(conversation: conversation, modelID: reply.modelID),
                reportedPercent: reply.usage.reportedPercent
            )
        case .kiro:
            return KiroContextUsage.read(file: conversation.sourceFile)
        case .antigravity:
            return AntigravityContextUsage.read(databaseFile: conversation.sourceFile)
        }
    }
}
