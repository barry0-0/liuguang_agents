import Foundation
import SQLite3

/// Antigravity keeps each generation's context size in its conversation database, in the newest row of
/// `gen_metadata`. The message at the field path `1, 9, 10` holds the tokens the context holds and the size of the
/// window they fill. Neither field number is documented; they were observed in Antigravity CLI 1.5.13.
enum AntigravityContextUsage {
    static func read(databaseFile: URL) -> ContextUsage? {
        guard let database = try? AntigravityDatabase.open(databaseFile) else { return nil }
        defer { sqlite3_close(database) }
        var statement: OpaquePointer?
        guard
            sqlite3_prepare_v2(database, "SELECT data FROM gen_metadata ORDER BY idx DESC LIMIT 1", -1, &statement, nil)
                == SQLITE_OK, let statement
        else { return nil }
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW,
            let metadata = AntigravityDatabase.blob(statement, column: 0),
            let context = AntigravityProtobuf.bytes(in: metadata, at: [1, 9, 10]),
            let used = AntigravityProtobuf.integer(in: context, field: usedField),
            let window = AntigravityProtobuf.integer(in: context, field: windowField)
        else { return nil }
        return ContextUsage(used: Int(clamping: used), window: Int(clamping: window))
    }

    /// The tokens the context holds.
    private static let usedField: UInt64 = 1
    /// The size of the window they fill.
    private static let windowField: UInt64 = 4
}
