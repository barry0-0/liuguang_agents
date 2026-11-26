import SwiftUI

struct TerminalRuntimeStatusStrip: View {
    let session: TerminalSession

    @State private var usage: ContextUsage?
    @State private var monitor: ContextUsageMonitor?
    @State private var feedback: String?

    private var provider: ConversationProvider? { session.provider }
    private var models: [CLIControlCatalog.ModelOption] { provider.map(CLIControlCatalog.models(for:)) ?? [] }
    private var permissions: [CLIControlCatalog.PermissionOption] { provider.map(CLIControlCatalog.permissions(for:)) ?? [] }
    private var currentModelID: String? {
        session.conversation.map(CLIControlCatalog.currentModelID(for:))
            ?? provider.flatMap(CLIControlCatalog.currentModelID(for:))
    }
    private var currentModelTitle: String {
        guard let currentModelID else { return "默认模型" }
        return models.first { $0.id == currentModelID }?.title ?? currentModelID
    }

    private var permissionText: String {
        guard let provider else { return "本地终端" }
        return provider.defaultPermissionArguments.isEmpty ? "CLI 默认权限" : "全权限"
    }

    private var commandText: String {
        let command = session.command
        return ([command.executablePath] + command.arguments).joined(separator: " ")
    }

    var body: some View {
        HStack(spacing: 8) {
            if let provider {
                Menu {
                    if models.isEmpty {
                        Text("未找到模型列表")
                    } else {
                        ForEach(models) { model in
                            Button(model.title) { selectModel(model.id) }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        provider.iconImage(size: 12)
                        Text(provider.rawValue)
                        Text(currentModelTitle)
                            .foregroundStyle(ThemePalette.secondaryText)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                    }
                }
                .font(.system(size: 10, weight: .medium))
                .help("选择当前 CLI 的模型")
                .id("\(provider.rawValue)-\(currentModelID ?? "")-\(models.count)")
            }

            Menu {
                if permissions.isEmpty {
                    Text("当前 CLI 无可选权限")
                } else {
                    ForEach(permissions) { permission in
                        Button(permission.title) { selectPermission(permission.id) }
                    }
                }
            } label: {
                Label(permissionText, systemImage: "lock.open")
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(ThemePalette.secondaryText)
            .help("选择当前 CLI 的权限模式")

            Button {
                monitor?.refresh()
                send("/status")
            } label: {
                Label(usage?.label ?? "上下文 —", systemImage: "chart.bar")
            }
            .buttonStyle(.plain)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(ThemePalette.secondaryText)
            .help("读取真实 token 用量并刷新 CLI 状态")

            Spacer(minLength: 6)
            if let feedback {
                Text(feedback)
                    .font(.system(size: 9))
                    .foregroundStyle(ThemePalette.tertiaryText)
                    .lineLimit(1)
            }
            Text(commandText)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(ThemePalette.tertiaryText)
                .lineLimit(1)
                .truncationMode(.middle)
                .help(commandText)
        }
        .padding(.horizontal, 12)
        .frame(height: 28)
        .background(ThemePalette.raisedSurface)
        .overlay(alignment: .bottom) { ThemeDivider() }
        .onAppear {
            monitor = makeMonitor()
            monitor?.start()
        }
        .onDisappear { monitor?.stop() }
        .onChange(of: session.conversation?.sourceFile) { _, _ in
            monitor?.stop()
            monitor = makeMonitor()
            monitor?.start()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(provider?.rawValue ?? "本地终端")，\(permissionText)，\(usage?.label ?? "上下文未知")")
    }

    private func makeMonitor() -> ContextUsageMonitor {
        ContextUsageMonitor(conversation: session.conversation) { usage = $0 }
    }

    private func selectModel(_ model: String) {
        switch provider {
        case .codex:
            send("/model \(model)")
        case .claude:
            send("/model \(model)")
        case .pi:
            session.terminalView.window?.makeFirstResponder(session.terminalView)
            session.terminalView.sendText("/model \(model)\r")
            feedback = "已发送 /model \(model)"
        default:
            feedback = "当前 CLI 无模型选择命令"
        }
    }

    private func selectPermission(_ permission: String) {
        guard let provider else { return }
        switch provider {
        case .codex:
            send("/permissions \(permission)")
        case .claude:
            feedback = "Claude 权限需在启动时设置：\(permission)"
        default:
            feedback = "当前 CLI 无可选权限"
        }
    }

    private func send(_ command: String) {
        guard provider != nil else {
            feedback = "当前 CLI 不支持此控制命令"
            return
        }
        session.terminalView.window?.makeFirstResponder(session.terminalView)
        session.sendTextAndClearAttachments(command + "\r")
        feedback = "已发送 \(command)"
    }
}
