import Foundation

/// Claude Code writes each assistant reply's token counts in the `usage` of the message it belongs to: the fresh
/// `input_tokens`, what it wrote to the provider's cache, and what it read back from it. The prompt of the next
/// request holds the fresh input and the cached part alike, so both count towards the window. The transcript keeps
/// no window of its own, so `ContextWindowLookup` reads the one Claude Code works with.
enum ClaudeContextUsage {
    static func read(file: URL) -> ContextUsage? {
        var result: ContextUsage?
        for line in JSONLinesReader.trailingLines(in: file, maximumByteCount: 1 << 20).reversed() {
            guard let record = ConversationMetadata.object(from: line),
                let message = record["message"] as? [String: Any],
                let usage = message["usage"] as? [String: Any],
                let input = usage["input_tokens"] as? Int
            else { continue }
            let cacheRead = usage["cache_read_input_tokens"] as? Int ?? 0
            let cacheWrite = usage["cache_creation_input_tokens"] as? Int ?? 0
            result = ContextUsage(used: input + cacheRead + cacheWrite, window: nil)
            break
        }
        return result
    }
}
