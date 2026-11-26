import SwiftUI

struct NotificationSettingsSection: View {
    @ObservedObject var settingsStore: SessionNotificationSettingsStore
    @State private var isTurnedOffInSystemSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Notify me when a session")
                    .font(ThemeFont.heading)
                HelpPopoverButton(
                    title: "Notifications",
                    explanation:
                        "支持 Claude Code、Codex、Antigravity、Pi、OpenCode 和 Kiro CLI。正在查看的会话不会通知你。点击通知可打开对应会话。"
                )
                .accessibilityIdentifier("settings.help.notifications")
            }
            Toggle(
                "Needs my input, such as a permission prompt",
                isOn: Binding(
                    get: { settingsStore.preferences.notifiesWhenInputNeeded },
                    set: { settingsStore.setNotifiesWhenInputNeeded($0) }
                ))
            Toggle(
                "Finishes its turn",
                isOn: Binding(
                    get: { settingsStore.preferences.notifiesWhenTurnFinishes },
                    set: { settingsStore.setNotifiesWhenTurnFinishes($0) }
                ))
            if isTurnedOffInSystemSettings {
                Text("Notifications for 流光 are turned off in System Settings > Notifications.")
                    .font(ThemeFont.caption)
                    .foregroundStyle(ThemePalette.warningText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task { await readSystemSettings() }
    }

    private func readSystemSettings() async {
        isTurnedOffInSystemSettings = await SystemPermissionChecker().status(of: .notifications) == .notAllowed
    }
}
