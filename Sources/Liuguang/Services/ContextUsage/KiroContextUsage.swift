import Foundation

/// Kiro CLI's V3 engine writes how much of its context window is used in a `session_metadata` event, under the key
/// `contextUsage`. It names no token counts of its own, so only the percentage is read.
enum KiroContextUsage {
    static func read(file: URL) -> ContextUsage? {
        var result: ContextUsage?
        for line in JSONLinesReader.trailingLines(in: file, maximumByteCount: 1 << 20).reversed() {
            guard let record = ConversationMetadata.object(from: line),
                let payload = record["payload"] as? [String: Any],
                payload["type"] as? String == "session_metadata",
                payload["key"] as? String == "contextUsage",
                let value = payload["value"] as? [String: Any],
                let percentage = value["usagePercentage"] as? Double
            else { continue }
            result = ContextUsage(used: 0, window: nil, reportedPercent: percentage)
            break
        }
        return result
    }
}
