import Foundation

enum AppIdentity {
    static let bundleIdentifier = "dev.barry.liuguang"

    static var currentBundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? bundleIdentifier
    }
}
