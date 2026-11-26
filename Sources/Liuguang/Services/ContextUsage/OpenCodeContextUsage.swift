import Foundation
import SQLite3

/// OpenCode keeps each message's token counts in the `data` of its row in the `message` table: the fresh `input`,
/// what it read back from the provider's cache, and what it wrote to it. OpenCode names no window in the database, so
/// `ContextWindowLookup` reads the one its model cache gives.
enum OpenCodeContextUsage {
    static func read(databaseFile: URL, sessionID: String) -> ContextUsage? {
        readReply(databaseFile: databaseFile, sessionID: sessionID)?.usage
    }

    /// The reply OpenCode wrote last, with the model it used, whose window `ContextWindowLookup` reads from the
    /// model cache.
    struct Reply {
        let usage: ContextUsage
        let modelID: String?
    }

    static func readReply(databaseFile: URL, sessionID: String) -> Reply? {
        guard FileManager.default.fileExists(atPath: databaseFile.path) else { return nil }
        var database: OpaquePointer?
        guard sqlite3_open_v2(databaseFile.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let database else {
            if let database { sqlite3_close(database) }
            return nil
        }
        defer { sqlite3_close(database) }
        sqlite3_busy_timeout(database, 1_000)

        var statement: OpaquePointer?
        let query = """
            SELECT data FROM message
            WHERE session_id = ? AND json_valid(data) AND json_extract(data, '$.role') = 'assistant'
            ORDER BY time_created DESC LIMIT 64
            """
        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK, let statement else { return nil }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

        var result: Reply?
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let bytes = sqlite3_column_text(statement, 0) else { continue }
            let data = Data(String(cString: bytes).utf8)
            guard let object = ConversationMetadata.object(from: data),
                let tokens = object["tokens"] as? [String: Any],
                let input = tokens["input"] as? Int
            else { continue }
            let cache = tokens["cache"] as? [String: Any]
            let cacheRead = cache?["read"] as? Int ?? 0
            let cacheWrite = cache?["write"] as? Int ?? 0
            result = Reply(
                usage: ContextUsage(used: input + cacheRead + cacheWrite, window: nil),
                modelID: object["modelID"] as? String
            )
            break
        }
        return result
    }
}
