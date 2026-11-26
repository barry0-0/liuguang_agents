import SwiftUI

@MainActor
enum SettingsTabPageMetrics {
    static var size: CGSize { CGSize(width: 600, height: 560) }
    static let sheetSize = CGSize(width: 760, height: 620)
    nonisolated static let contentPadding: CGFloat = 24
}

struct SettingsTabPage<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(.vertical) {
            content()
                .padding(SettingsTabPageMetrics.contentPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: SettingsTabPageMetrics.size.width, height: SettingsTabPageMetrics.size.height)
        .background(ThemePalette.contentSurface)
    }
}
