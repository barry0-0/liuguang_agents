import Foundation
import Testing

@testable import Liuguang

struct OpenCodeContextUsageTests {
    @Test func readsTheTokensOfTheLastReply() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let databaseFile = directory.appendingPathComponent("opencode.db")
        let fixture = try OpenCodeDatabaseFixture(file: databaseFile)
        try fixture.addSession("ses_1")
        try fixture.addMessage(
            "msg_1",
            session: "ses_1",
            createdAt: 1_790_000_000_000,
            data: [
                "role": "assistant",
                "tokens": ["input": 66_969, "output": 291, "cache": ["read": 1_920, "write": 0]],
            ]
        )
        try fixture.addMessage(
            "msg_2",
            session: "ses_1",
            createdAt: 1_790_000_001_000,
            data: [
                "role": "assistant",
                "tokens": ["input": 56_299, "output": 215, "cache": ["read": 0, "write": 0]],
            ]
        )

        let usage = OpenCodeContextUsage.read(databaseFile: databaseFile, sessionID: "ses_1")

        #expect(usage?.used == 56_299)
    }

    @Test func aSessionWithoutRepliesHasNoUsage() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let databaseFile = directory.appendingPathComponent("opencode.db")
        let fixture = try OpenCodeDatabaseFixture(file: databaseFile)
        try fixture.addSession("ses_1")
        try fixture.addUserPrompt("msg_1", session: "ses_1", createdAt: 1_790_000_000_000, text: "Fix it")

        #expect(OpenCodeContextUsage.read(databaseFile: databaseFile, sessionID: "ses_1") == nil)
    }
}
