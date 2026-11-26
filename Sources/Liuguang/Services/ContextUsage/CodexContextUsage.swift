import Foundation

/// Codex writes each turn's token counts as an `event_msg` whose payload is a `token_count`, and its newer builds
/// write the same counts as a top-level `token_usage_record`. The count is the prompt of the last request, so the
/// window it fills is the one the next request has to fit into.
enum CodexContextUsage {
    static func read(file: URL) -> ContextUsage? {
        var newest: ContextUsage?
        for line in JSONLinesReader.trailingLines(in: file, maximumByteCount: 1 << 20).reversed() {
            guard let record = ConversationMetadata.object(from: line) else { continue }
            if let usage = fromEventMessage(record) {
                newest = usage
                break
            }
            if newest == nil, let usage = fromUsageRecord(record) {
                newest = usage
            }
        }
        return newest
    }

    private static func fromEventMessage(_ record: [String: Any]) -> ContextUsage? {
        guard record["type"] as? String == "event_msg",
            let payload = record["payload"] as? [String: Any],
            payload["type"] as? String == "token_count",
            let info = payload["info"] as? [String: Any],
            let usage = info["last_token_usage"] as? [String: Any],
            let input = usage["input_tokens"] as? Int
        else { return nil }
        return ContextUsage(used: input, window: info["model_context_window"] as? Int)
    }

    private static func fromUsageRecord(_ record: [String: Any]) -> ContextUsage? {
        guard record["type"] as? String == "token_usage_record",
            let payload = record["payload"] as? [String: Any],
            let usage = payload["usage"] as? [String: Any],
            let input = usage["input_tokens"] as? Int
        else { return nil }
        return ContextUsage(used: input, window: nil)
    }
}
