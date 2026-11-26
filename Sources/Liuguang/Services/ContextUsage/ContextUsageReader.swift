import Foundation

/// Reads how much of its context window each CLI's session fills, from the files the CLI writes itself.
///
/// Every CLI records its last request's token counts in its own format, and only Codex records the size of its
/// window beside them. The others get their window from the CLI's own configuration, as
/// `ContextWindowLookup` reads it.
enum ContextUsageReader {
    static func read(conversation: Conversation?) -> ContextUsage? {
        guard let conversation else { return nil }
        let usage: ContextUsage?
        switch conversation.provider {
        case .codex:
            usage = CodexContextUsage.read(file: conversation.sourceFile)
        case .claude:
            usage = ClaudeContextUsage.read(file: conversation.sourceFile)
        case .pi:
            usage = PiContextUsage.read(file: conversation.sourceFile)
        case .opencode:
            usage = OpenCodeContextUsage.read(databaseFile: conversation.sourceFile, sessionID: conversation.sessionID)
        case .kiro:
            usage = KiroContextUsage.read(file: conversation.sourceFile)
        case .antigravity:
            usage = AntigravityContextUsage.read(databaseFile: conversation.sourceFile)
        }
        guard let usage else { return nil }
        guard let window = usage.window else {
            return ContextUsage(
                used: usage.used,
                window: ContextWindowLookup.window(for: conversation.provider, conversation: conversation),
                reportedPercent: usage.reportedPercent
            )
        }
        return usage
    }
}
