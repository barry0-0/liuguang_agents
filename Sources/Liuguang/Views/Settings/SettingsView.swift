import SwiftUI

struct SettingsView: View {
    @Binding var selectedTab: SettingsTab
    let hosts: [SessionHost]
    let conversationStore: ConversationStore
    let languageStore: AppLanguageStore
    let tabReopeningSettingsStore: TabReopeningSettingsStore
    let launchAtLoginSettingsStore: LaunchAtLoginSettingsStore
    let tabCloseChoiceSettingsStore: TabCloseChoiceSettingsStore
    let plainTerminalCloseChoiceSettingsStore: PlainTerminalCloseChoiceSettingsStore
    let fileLinkClickSettingsStore: FileLinkClickSettingsStore
    let editorStore: ExternalEditorStore
    let appAppearanceStore: AppAppearanceStore
    let appThemeStore: AppThemeStore
    let terminalAppearanceStore: TerminalAppearanceStore
    let terminalEngineStore: TerminalEngineStore
    let terminalOptionKeyStore: TerminalOptionKeyStore
    let notificationSettingsStore: SessionNotificationSettingsStore

    var body: some View {
        HStack(spacing: 0) {
            settingsMenu

            ThemeDivider()

            SettingsTabPage {
                switch selectedTab {
                case .general:
                    GeneralSettingsView(
                        hosts: hosts,
                        conversationStore: conversationStore,
                        languageStore: languageStore,
                        tabReopeningSettingsStore: tabReopeningSettingsStore,
                        launchAtLoginSettingsStore: launchAtLoginSettingsStore,
                        tabCloseChoiceSettingsStore: tabCloseChoiceSettingsStore,
                        plainTerminalCloseChoiceSettingsStore: plainTerminalCloseChoiceSettingsStore,
                        fileLinkClickSettingsStore: fileLinkClickSettingsStore,
                        editorStore: editorStore,
                        notificationSettingsStore: notificationSettingsStore,
                    )
                case .appearance:
                    AppearanceSettingsView(
                        appAppearanceStore: appAppearanceStore,
                        appThemeStore: appThemeStore,
                        terminalAppearanceStore: terminalAppearanceStore,
                        terminalOptionKeyStore: terminalOptionKeyStore
                    )
                case .permissions:
                    PermissionsSettingsView()
                case .help:
                    HelpSettingsView()
                case .releaseNotes:
                    ReleaseNotesSettingsView(onShowGeneral: { selectedTab = .general })
                }
            }
            .id(selectedTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemePalette.contentSurface)
    }

    private var settingsMenu: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("设置")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.bottom, 12)
            ForEach(SettingsTab.switcherTabs) { tab in
                settingsMenuButton(tab)
            }
            Spacer()
        }
        .padding(16)
        .frame(width: 170)
        .background(ThemePalette.sidebarSurface)
    }

    private func settingsMenuButton(_ tab: SettingsTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack {
                Image(systemName: settingsSymbol(tab))
                Text(tab.title)
                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
            .contentShape(Rectangle())
            .foregroundColor(selectedTab.switcherTab == tab ? .primary : .secondary)
            .background {
                if selectedTab.switcherTab == tab {
                    RoundedRectangle(cornerRadius: 5).fill(Color.accentColor.opacity(0.14))
                }
            }
        }
        .buttonStyle(.plain)
        .focusable(false)
    }

    private func settingsSymbol(_ tab: SettingsTab) -> String {
        switch tab {
        case .general: "gearshape"
        case .appearance: "paintbrush"
        case .permissions: "hand.raised"
        case .help: "questionmark.circle"
        case .releaseNotes: "doc.text"
        }
    }
}
