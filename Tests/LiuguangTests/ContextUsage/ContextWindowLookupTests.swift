import Foundation
import Testing

@testable import Liuguang

struct ContextWindowLookupTests {
    @Test func claudeTakesTheWindowFromItsSettings() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let settings = directory.appendingPathComponent("settings.json")
        try Data(#"{"env":{"CLAUDE_CODE_MAX_CONTEXT_TOKENS":"960000"}}"#.utf8).write(to: settings)

        let window = ContextWindowLookup.claudeWindow(
            conversation: nil,
            settingsFile: settings,
            environment: [:]
        )

        #expect(window == 960_000)
    }

    @Test func claudeTakesTheLargerWindowFromTheModelSuffix() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let settings = directory.appendingPathComponent("settings.json")
        try Data(#"{"model":"sonnet[1m]"}"#.utf8).write(to: settings)
        let conversation = Conversation.fixture(provider: .claude, model: SessionModel(id: "sonnet[1m]"))

        let window = ContextWindowLookup.claudeWindow(
            conversation: conversation,
            settingsFile: settings,
            environment: [:]
        )

        #expect(window == 1_000_000)
    }

    @Test func claudeHasNoWindowWithoutOneConfigured() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let settings = directory.appendingPathComponent("settings.json")
        try Data(#"{"model":"sonnet"}"#.utf8).write(to: settings)

        let window = ContextWindowLookup.claudeWindow(conversation: nil, settingsFile: settings, environment: [:])

        #expect(window == nil)
    }

    @Test func piTakesTheWindowFromItsModelCatalog() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let catalog = directory.appendingPathComponent("models.json")
        try Data(
            #"{"providers":{"magpie":{"models":[{"id":"workbuddy/hy4free","contextWindow":960000}]}}}"#.utf8
        ).write(to: catalog)
        let conversation = Conversation.fixture(provider: .pi, model: SessionModel(id: "workbuddy/hy4free"))

        let window = ContextWindowLookup.piWindow(conversation: conversation, catalogFile: catalog)

        #expect(window == 960_000)
    }

    @Test func openCodeTakesTheWindowFromItsModelCache() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let catalog = directory.appendingPathComponent("models.json")
        try Data(
            #"{"magpie":{"models":{"workbuddy/hy4free":{"id":"workbuddy/hy4free","limit":{"context":1048576}}}}}"#.utf8
        ).write(to: catalog)
        let conversation = Conversation.fixture(provider: .opencode, model: SessionModel(id: "workbuddy/hy4free"))

        let window = ContextWindowLookup.openCodeWindow(conversation: conversation, catalogFile: catalog)

        #expect(window == 1_048_576)
    }

    @Test func aModelTheCatalogDoesNotNameHasNoWindow() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let catalog = directory.appendingPathComponent("models.json")
        try Data(#"{"providers":{}}"#.utf8).write(to: catalog)
        let conversation = Conversation.fixture(provider: .pi, model: SessionModel(id: "workbuddy/hy4free"))

        #expect(ContextWindowLookup.piWindow(conversation: conversation, catalogFile: catalog) == nil)
        #expect(ContextWindowLookup.openCodeWindow(conversation: conversation, catalogFile: catalog) == nil)
    }
}
