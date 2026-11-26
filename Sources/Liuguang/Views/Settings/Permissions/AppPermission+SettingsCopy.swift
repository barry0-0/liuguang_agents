import SwiftUI

extension AppPermission {
    var title: LocalizedStringKey {
        switch self {
        case .notifications: "通知"
        case .fullDiskAccess: "完全磁盘访问权限"
        case .accessibility: "辅助功能"
        case .localNetwork: "本地网络"
        }
    }

    var explanation: LocalizedStringKey {
        switch self {
        case .notifications:
            "允许 流光 在会话需要你输入或完成任务时通知你。具体通知项在“通用”中选择。"
        case .fullDiskAccess:
            "可选。没有它时，终端中的 CLI 首次访问文稿或外接磁盘等受保护目录，macOS 会逐个询问。"
        case .accessibility:
            "可选。允许终端中的 CLI 控制其他 App，例如通过 System Events 点击菜单或输入按键。终端中的 CLI 都会获得该权限，请确认需要后再允许。"
        case .localNetwork:
            "流光 和终端中的 CLI 需要它访问局域网设备。macOS 不允许 App 自行检查，请在“隐私与安全性 → 本地网络”中查看 流光。"
        }
    }
}
