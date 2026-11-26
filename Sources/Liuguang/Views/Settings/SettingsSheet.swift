import SwiftUI

struct SettingsSheet: View {
    @Binding var selectedTab: SettingsTab
    let store: ConversationStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SettingsView(
                selectedTab: $selectedTab,
                hosts: store.hosts.filter { $0 == .thisMac },
                conversationStore: store,
                languageStore: .shared,
                tabReopeningSettingsStore: .shared,
                launchAtLoginSettingsStore: .shared,
                tabCloseChoiceSettingsStore: .shared,
                plainTerminalCloseChoiceSettingsStore: .shared,
                fileLinkClickSettingsStore: .shared,
                editorStore: .shared,
                appAppearanceStore: .shared,
                appThemeStore: .shared,
                terminalAppearanceStore: .shared,
                terminalEngineStore: .shared,
                terminalOptionKeyStore: .shared,
                notificationSettingsStore: .shared,
            )
            ThemeDivider()
            HStack {
                Spacer()
                Button("完成") { dismiss() }
                    .buttonStyle(ThemeProminentButtonStyle())
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(height: 44)
        }
        .frame(width: SettingsTabPageMetrics.sheetSize.width, height: SettingsTabPageMetrics.sheetSize.height)
        .background(ThemePalette.contentSurface)
        .background(SettingsSheetTerminationPolicy())
        .fixedSize()
        .environment(
            \.showAppWideSheet,
            ShowAppWideSheetAction { requestedSheet in
                selectedTab = requestedSheet.selectedSettingsTab
            }
        )
        .appLanguage(from: .shared)
    }
}
