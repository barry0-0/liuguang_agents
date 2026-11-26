import SwiftUI

struct SidebarSettingsSection: View {
    let store: ConversationStore
    @AppStorage(SidebarSubagentRows.showsSubagentsUserDefaultsKey) private var showsSubagents = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sidebar")
                .font(ThemeFont.heading)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Toggle("Show subagents under the sessions that started them", isOn: $showsSubagents)
                    .accessibilityIdentifier("settings.showsSubagents")
                HelpPopoverButton(
                    title: "Subagents",
                    explanation:
                        "子代理另开了会话时，原会话前会出现箭头。点击后在会话下方列出并阅读这些子会话。Kiro 的子会话不列出。"
                )
                .accessibilityIdentifier("settings.help.subagents")
            }
            ShownSessionProvidersPicker(store: store)
        }
    }
}
