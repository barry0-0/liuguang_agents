import Foundation

struct FullDiskAccessProbe: Sendable {
    var protectedFiles: [String] = [
        NSHomeDirectory() + "/Library/Application Support/com.apple.TCC/TCC.db",
        NSHomeDirectory() + "/Library/Safari/Bookmarks.plist",
        NSHomeDirectory() + "/Library/Mail",
        NSHomeDirectory() + "/Library/Messages",
    ]

    func status() -> AppPermissionStatus {
        for path in protectedFiles {
            let descriptor = open(path, O_RDONLY)
            if descriptor >= 0 {
                close(descriptor)
                return .allowed
            }
        }
        return .notAllowed
    }
}
