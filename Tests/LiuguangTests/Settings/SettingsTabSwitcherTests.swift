import Testing

@testable import Liuguang

struct SettingsTabSwitcherTests {
    @Test func theSwitcherLeavesOutReleaseNotesAndKeepsGeneralSelectedForIt() {
        #expect(!SettingsTab.switcherTabs.contains(.releaseNotes))
        #expect(SettingsTab.switcherTabs == SettingsTab.allCases.filter { $0 != .releaseNotes })
        #expect(SettingsTab.releaseNotes.switcherTab == .general)
        for tab in SettingsTab.switcherTabs {
            #expect(tab.switcherTab == tab)
        }
    }
}
