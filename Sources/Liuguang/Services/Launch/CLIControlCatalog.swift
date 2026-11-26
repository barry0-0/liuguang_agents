import Foundation

enum CLIControlCatalog {
    struct ModelOption: Identifiable, Hashable {
        let id: String
        let title: String
    }

    struct PermissionOption: Identifiable, Hashable {
        let id: String
        let title: String
    }

    static func models(for provider: ConversationProvider) -> [ModelOption] {
        switch provider {
        case .codex: return codexModels()
        case .claude: return claudeModels()
        case .pi: return piModels()
        default: return []
        }
    }

    static func currentModelID(for provider: ConversationProvider) -> String? {
        switch provider {
        case .codex: return tomlValue("model", in: homePath(".codex/config.toml"))
        case .claude: return jsonValue("model", in: homePath(".claude/settings.json"))
        case .pi: return jsonValue("defaultModel", in: homePath(".pi/agent/settings.json"))
        default: return nil
        }
    }

    static func currentModelID(for conversation: Conversation) -> String? {
        switch conversation.provider {
        case .codex:
            return CodexRolloutModel.latest(in: conversation.sourceFile)?.id ?? currentModelID(for: .codex)
        case .claude:
            return conversation.model?.id ?? ClaudeTranscriptTail.model(in: conversation.sourceFile) ?? currentModelID(for: .claude)
        case .pi:
            return PiSessionCurrentModel.latest(in: conversation.sourceFile) ?? currentModelID(for: .pi)
        default:
            return currentModelID(for: conversation.provider)
        }
    }

    private static func codexModels() -> [ModelOption] {
        guard let path = codexModelCatalogPath(),
              let data = try? Data(contentsOf: path),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let models = object["models"] as? [[String: Any]]
        else { return [] }
        return models.compactMap { model in
            guard let slug = model["slug"] as? String, !slug.isEmpty else { return nil }
            let title = model["display_name"] as? String ?? slug
            return ModelOption(id: slug, title: title)
        }
    }

    private static func claudeModels() -> [ModelOption] {
        guard let data = try? Data(contentsOf: homePath(".claude/settings.json")),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let picker = object["modelPicker"] as? [String: Any],
              let options = picker["options"] as? [[String: Any]]
        else { return [] }
        return options.compactMap { option in
            guard let model = option["model"] as? String, !model.isEmpty else { return nil }
            let title = option["label"] as? String ?? model
            return ModelOption(id: model, title: title)
        }
    }

    private static func piModels() -> [ModelOption] {
        guard let data = try? Data(contentsOf: homePath(".pi/agent/models.json")),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let providers = object["providers"] as? [String: Any]
        else { return [] }
        return providers.values.compactMap { provider in
            (provider as? [String: Any])?["models"] as? [[String: Any]]
        }.flatMap { models in
            models.compactMap { model in
                guard let id = model["id"] as? String, !id.isEmpty else { return nil }
                let title = model["name"] as? String ?? id
                return ModelOption(id: id, title: title)
            }
        }
    }

    static func permissions(for provider: ConversationProvider) -> [PermissionOption] {
        switch provider {
        case .codex:
            return [
                PermissionOption(id: "read-only", title: "只读"),
                PermissionOption(id: "workspace-write", title: "工作区写入"),
                PermissionOption(id: "danger-full-access", title: "全权限"),
            ]
        case .claude:
            return [
                PermissionOption(id: "manual", title: "手动确认"),
                PermissionOption(id: "acceptEdits", title: "自动编辑"),
                PermissionOption(id: "auto", title: "自动"),
                PermissionOption(id: "plan", title: "计划"),
                PermissionOption(id: "dontAsk", title: "不询问"),
                PermissionOption(id: "bypassPermissions", title: "全权限"),
            ]
        default:
            return []
        }
    }

    private static func codexModelCatalogPath() -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let configURL = homePath(".codex/config.toml")
        guard let text = try? String(contentsOf: configURL, encoding: .utf8) else { return nil }
        let prefix = "model_catalog_json"
        guard let line = text.split(whereSeparator: \.isNewline).first(where: { $0.hasPrefix(prefix) }),
              let firstQuote = line.firstIndex(of: "\""),
              let lastQuote = line.lastIndex(of: "\""),
              firstQuote < lastQuote
        else { return nil }
        let path = String(line[line.index(after: firstQuote)..<lastQuote])
        return path.hasPrefix("/") ? URL(fileURLWithPath: path) : home.appendingPathComponent(path)
    }

    private static func homePath(_ relativePath: String) -> URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(relativePath)
    }

    private static func jsonValue(_ key: String, in url: URL) -> String? {
        guard let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return object[key] as? String
    }

    private static func tomlValue(_ key: String, in url: URL) -> String? {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        for line in text.split(whereSeparator: \.isNewline) where line.hasPrefix(key) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix(key + " "), trimmed.contains("=") else { continue }
            guard let firstQuote = line.firstIndex(of: "\""), let lastQuote = line.lastIndex(of: "\""),
                  firstQuote < lastQuote else { continue }
            return String(line[line.index(after: firstQuote)..<lastQuote])
        }
        return nil
    }
}

enum PiSessionCurrentModel {
    static func latest(in file: URL) -> String? {
        var result: String?
        for line in JSONLinesReader.trailingLines(in: file, maximumByteCount: 1 << 20) {
            guard let record = ConversationMetadata.object(from: line),
                  record["type"] as? String == "model_change",
                  let modelID = record["modelId"] as? String, !modelID.isEmpty
            else { continue }
            result = modelID
        }
        return result
    }
}
