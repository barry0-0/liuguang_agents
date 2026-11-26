import Foundation
import Testing

@testable import Liuguang

struct ContextUsageReaderTests {
    @Test func claudeCountsTheCachedPartOfItsLastPrompt() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("session.jsonl")
        try writeLines(
            [
                #"{"type":"assistant","message":{"usage":{"input_tokens":226,"cache_read_input_tokens":445184,"cache_creation_input_tokens":100,"output_tokens":473}}}"#
            ],
            to: file
        )

        let usage = ClaudeContextUsage.read(file: file)

        #expect(usage?.used == 445_510)
        #expect(usage?.window == nil)
    }

    @Test func codexReadsTheWindowBesideItsTokenCounts() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("rollout.jsonl")
        try writeLines(
            [
                #"{"type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":113166},"model_context_window":950000}}}"#
            ],
            to: file
        )

        let usage = CodexContextUsage.read(file: file)

        #expect(usage?.used == 113_166)
        #expect(usage?.window == 950_000)
    }

    @Test func codexFallsBackToItsNewerUsageRecord() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("rollout.jsonl")
        try writeLines(
            [
                #"{"type":"token_usage_record","payload":{"usage":{"input_tokens":219821}}}"#
            ],
            to: file
        )

        let usage = CodexContextUsage.read(file: file)

        #expect(usage?.used == 219_821)
    }

    @Test func piCountsTheCachedPartOfItsLastPrompt() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("session.jsonl")
        try writeLines(
            [
                #"{"type":"message","message":{"usage":{"input":1947,"cacheRead":27136,"cacheWrite":0}}}"#
            ],
            to: file
        )

        let usage = PiContextUsage.read(file: file)

        #expect(usage?.used == 29_083)
    }

    @Test func kiroReadsThePercentageItReports() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("messages.jsonl")
        try writeLines(
            [
                #"{"id":"event-1","timestamp":"2026-10-23T23:23:01.000Z","payload":{"type":"session_metadata","key":"contextUsage","value":{"usagePercentage":2.6}}}"#
            ],
            to: file
        )

        let usage = KiroContextUsage.read(file: file)

        #expect(usage?.reportedPercent == 2.6)
        #expect(usage?.label == "2%")
    }

    @Test func aSessionWithoutTokenCountsHasNoUsage() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("session.jsonl")
        try writeLines([#"{"type":"user","message":{"role":"user"}}"#], to: file)

        #expect(ClaudeContextUsage.read(file: file) == nil)
        #expect(CodexContextUsage.read(file: file) == nil)
        #expect(PiContextUsage.read(file: file) == nil)
        #expect(KiroContextUsage.read(file: file) == nil)
    }

    private func writeLines(_ lines: [String], to file: URL) throws {
        try Data((lines.joined(separator: "\n") + "\n").utf8).write(to: file)
    }
}
