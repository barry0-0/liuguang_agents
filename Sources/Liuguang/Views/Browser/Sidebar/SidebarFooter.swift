import SwiftUI

struct SidebarFooter: View {
    var body: some View {
        HStack(spacing: 0) {
            SidebarSettingsButton()
                .buttonStyle(ThemePlainButtonStyle(horizontalPadding: 6))
                .foregroundStyle(ThemePalette.ink)
                .font(ThemeFont.callout)
                .padding(.leading, 10)
            Spacer(minLength: 0)
        }
        .frame(height: InterfaceScale.points(34))
    }
}
