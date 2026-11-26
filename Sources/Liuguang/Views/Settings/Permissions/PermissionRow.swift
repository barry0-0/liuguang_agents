import SwiftUI

struct PermissionRow: View {
    let permission: AppPermission
    let status: AppPermissionStatus?
    let onAskForNotifications: () -> Void
    var onAskForAccessibility: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(permission.title)
                    .font(ThemeFont.heading)
                if permission.isOptional {
                    Text("可选")
                        .font(ThemeFont.caption)
                        .foregroundStyle(ThemePalette.secondaryText)
                }
                HelpPopoverButton(title: permission.title, explanation: permission.explanation)
                    .accessibilityIdentifier("settings.help.permission.\(permission.id)")
                Spacer(minLength: 12)
                if let status {
                    AppPermissionStatusLabel(status: status, isOptional: permission.isOptional)
                }
            }
            HStack(spacing: 8) {
                if permission == .notifications, status == .notAskedYet {
                    Button("请求授权", action: onAskForNotifications)
                }
                if permission == .accessibility {
                    Button("请求辅助功能授权") { onAskForAccessibility?() }
                        .help("点击后由 macOS 弹出系统授权；若旧授权已存在，请先删除再重新添加当前 流光.app")
                }
                Button("打开系统设置") { permission.openSystemSettings() }
            }
            .buttonStyle(QuietBorderedButtonStyle())
            .controlSize(.small)
            .padding(.top, 2)
        }
        .accessibilityElement(children: .contain)
    }
}
