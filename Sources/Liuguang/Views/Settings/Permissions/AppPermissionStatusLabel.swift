import SwiftUI

struct AppPermissionStatusLabel: View {
    let status: AppPermissionStatus
    let isOptional: Bool

    var body: some View {
        let label = Label {
            Text(title)
        } icon: {
            Image(systemName: symbolName).foregroundStyle(symbolColor)
        }
        .font(ThemeFont.callout)
        if let help {
            label.help(help)
        } else {
            label
        }
    }

    private var title: LocalizedStringKey {
        switch status {
        case .allowed: "已允许"
        case .notAllowed: isOptional ? "未检测允许（可能已授权）" : "未允许"
        case .notAskedYet: "尚未询问"
        case .unknown: "无法检查"
        }
    }

    private var symbolName: String {
        switch status {
        case .allowed: "checkmark.circle.fill"
        case .notAllowed: isOptional ? "minus.circle" : "exclamationmark.triangle.fill"
        case .notAskedYet: "circle.dashed"
        case .unknown: "questionmark.circle"
        }
    }

    private var symbolColor: AnyShapeStyle {
        switch status {
        case .allowed: AnyShapeStyle(ThemePalette.live)
        case .notAllowed where !isOptional: AnyShapeStyle(ThemePalette.warning)
        case .notAllowed, .notAskedYet, .unknown: AnyShapeStyle(ThemePalette.secondaryText)
        }
    }

    private var help: LocalizedStringKey? {
        switch status {
        case .allowed: nil
        case .notAllowed where isOptional:
            "macOS 不提供可靠的直接检测。若系统设置中已开启，可忽略此状态；重新签名后需删除旧授权项并重新添加当前 流光.app。"
        case .notAllowed: nil
        case .notAskedYet: "macOS 会在 流光 首次需要它时询问。"
        case .unknown: "macOS 不允许 App 检查。请在系统设置中查找 流光。"
        }
    }
}
