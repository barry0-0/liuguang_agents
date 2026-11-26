import Foundation

/// The size of the context window each CLI works with, read from the CLI's own configuration.
///
/// Only Codex writes its window beside its token counts. Claude Code takes it from
/// `CLAUDE_CODE_MAX_CONTEXT_TOKENS` in its settings, Pi and OpenCode from their model catalogs, and Antigravity
/// from the model its session used.
enum ContextWindowLookup {
    /// Claude Code keeps the window it assumes in `CLAUDE_CODE_MAX_CONTEXT_TOKENS`, which its settings' `env` may
    /// set, and its `model` may carry the `[1m]` suffix that names the larger window.
    static func claudeWindow(
        conversation: Conversation?,
        settingsFile: URL = ContextWindowLookup.claudeSettingsFile,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Int? {
        if let configured = environment["CLAUDE_CODE_MAX_CONTEXT_TOKENS"], let value = Int(configured), value > 0 {
            return value
        }
        if let settings = jsonObject(at: settingsFile),
            let env = settings["env"] as? [String: Any],
            let configured = env["CLAUDE_CODE_MAX_CONTEXT_TOKENS"] as? String,
            let value = Int(configured),
            value > 0
        {
            return value
        }
        let model = conversation?.model?.id ?? configuredClaudeModel(in: settingsFile)
        guard let model else { return nil }
        return model.hasSuffix("[1m]") ? 1_000_000 : nil
    }

    private static func configuredClaudeModel(in settingsFile: URL) -> String? {
        jsonObject(at: settingsFile)?["model"] as? String
    }

    /// Pi names each model's window in its catalog, under the provider the session used.
    static func piWindow(
        conversation: Conversation?,
        catalogFile: URL = ContextWindowLookup.piCatalogFile
    ) -> Int? {
        guard let conversation,
            let model = conversation.model?.id,
            let catalog = jsonObject(at: catalogFile)
        else { return nil }
        guard let providers = catalog["providers"] as? [String: Any] else { return piFallbackWindow }
        for provider in providers.values {
            guard let models = (provider as? [String: Any])?["models"] as? [[String: Any]] else { continue }
            for entry in models where entry["id"] as? String == model {
                if let window = entry["contextWindow"] as? Int, window > 0 { return window }
            }
        }
        return piFallbackWindow
    }

    /// The window Pi assumes for a model its catalog does not name, such as one a gateway serves under a name of its
    /// own.
    static let piFallbackWindow = 128_000

    /// OpenCode names each model's window in the cache it keeps, under the provider and model the session used.
    static func openCodeWindow(
        conversation: Conversation?,
        catalogFile: URL = ContextWindowLookup.openCodeCatalogFile,
        modelID: String? = nil
    ) -> Int? {
        guard let model = modelID ?? conversation?.model?.id else { return nil }
        guard let catalog = jsonObject(at: catalogFile) else { return nil }
        guard let providers = catalog as? [String: Any] else { return openCodeFallbackWindow }
        for provider in providers.values {
            guard let models = (provider as? [String: Any])?["models"] as? [String: Any] else { continue }
            for (identifier, entry) in models {
                guard identifier == model || (entry as? [String: Any])?["id"] as? String == model else { continue }
                if let limit = (entry as? [String: Any])?["limit"] as? [String: Any],
                    let window = limit["context"] as? Int,
                    window > 0
                {
                    return window
                }
            }
        }
        return openCodeFallbackWindow
    }

    /// The window OpenCode assumes for a model its cache does not name, such as one a plugin serves under a name of
    /// its own.
    static let openCodeFallbackWindow = 128_000

    private static func jsonObject(at file: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    private static var homeDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
    }

    static var claudeSettingsFile: URL {
        homeDirectory.appendingPathComponent(".claude/settings.json")
    }

    static var piCatalogFile: URL {
        homeDirectory.appendingPathComponent(".pi/agent/models.json")
    }

    static var openCodeCatalogFile: URL {
        homeDirectory.appendingPathComponent(".cache/opencode/models.json")
    }
}
