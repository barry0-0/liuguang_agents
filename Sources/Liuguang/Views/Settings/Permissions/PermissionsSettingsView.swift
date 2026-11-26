import AppKit
import SwiftUI

struct PermissionsSettingsView: View {
    var checker = SystemPermissionChecker()
    @State private var statuses: [AppPermission: AppPermissionStatus] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("权限")
                    .font(ThemeFont.heading)
                HelpPopoverButton(
                    title: "权限",
                    explanation:
                        "辅助功能授权属于当前 流光.app 身份。每次重新签名并覆盖安装后，系统设置里的旧授权可能失效。请优先点击“请求辅助功能授权”；若系统设置中已有旧条目，请删除后重新添加当前 /Applications/流光.app。此页不会自动弹窗。"
                )
                .accessibilityIdentifier("settings.help.permissions")
            }

            ForEach(AppPermission.onThisMac) { permission in
                ThemeDivider()
                PermissionRow(permission: permission, status: statuses[permission]) {
                    Task {
                        _ = await SessionNotificationCenter.requestAuthorization()
                        await checkAll()
                    }
                } onAskForAccessibility: {
                    Task {
                        _ = checker.accessibilityTrustProbe.request()
                        try? await Task.sleep(for: .seconds(1))
                        await checkAll()
                    }
                }
            }

            ThemeDivider()
            HStack {
                Spacer()
                Button("重新检查") { Task { await checkAll() } }
                    .buttonStyle(QuietBorderedButtonStyle())
            }
        }
        .task { await checkAll() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await checkAll() }
        }
    }

    private func checkAll() async {
        for permission in AppPermission.onThisMac {
            statuses[permission] = await checker.status(of: permission)
        }
    }
}
