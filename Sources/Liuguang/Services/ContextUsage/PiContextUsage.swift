import Foundation

/// Pi writes each reply's token counts in the `usage` of the message it belongs to: the fresh `input`, what it read
/// back from the provider's cache, and what it wrote to it. Pi keeps no window in the session file, so
/// `ContextWindowLookup` reads the one its model catalog gives.
enum PiContextUsage {
    static func read(file: URL) -> ContextUsage? {
        var result: ContextUsage?
        for line in JSONLinesReader.trailingLines(in: file, maximumByteCount: 1 << 20).reversed() {
            guard let record = ConversationMetadata.object(from: line),
                record["type"] as? String == "message",
                let message = record["message"] as? [String: Any],
                let usage = message["usage"] as? [String: Any],
                let input = usage["input"] as? Int
            else { continue }
            let cacheRead = usage["cacheRead"] as? Int ?? 0
            let cacheWrite = usage["cacheWrite"] as? Int ?? 0
            result = ContextUsage(used: input + cacheRead + cacheWrite, window: nil)
            break
        }
        return result
    }
}
