import Foundation

@testable import Liuguang

@MainActor
final class RecordingSessionNotifier: SessionNotifying {
    var isApplicationActive = false
    private(set) var notifications: [SessionNotification] = []

    func notify(_ notification: SessionNotification) {
        notifications.append(notification)
    }
}
