import Foundation
import AppKit

struct ProjectFolderDeletion {
    var moveToTrash: (URL) throws -> Void = { url in
        var destination: NSURL?
        try FileManager.default.trashItem(at: url, resultingItemURL: &destination)
    }

    @discardableResult
    func moveToTrash(_ projectPaths: Set<String>, fileManager: FileManager = .default) throws -> [String] {
        let sortedPaths = projectPaths.sorted()
        var moved: [String] = []
        do {
            for path in sortedPaths {
                let url = URL(fileURLWithPath: path).standardizedFileURL
                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
                    throw ProjectFolderDeletionError.folderMissing(path)
                }
                try moveToTrash(url)
                moved.append(path)
            }
        } catch {
            guard moved.count > 1 else { throw error }
            for path in moved.reversed() {
                _ = try? fileManager.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true)
            }
            var restoredURLs: [URL] = []
            for path in moved.reversed() {
                let url = URL(fileURLWithPath: path).standardizedFileURL
                if fileManager.fileExists(atPath: url.path) { restoredURLs.append(url) }
            }
            for url in restoredURLs {
                guard fileManager.fileExists(atPath: url.path) else { continue }
                _ = try? moveToTrash(url)
            }
            throw error
        }
        return moved
    }
}

enum ProjectFolderDeletionError: LocalizedError, Equatable {
    case folderMissing(String)

    var errorDescription: String? {
        switch self {
        case .folderMissing(let path): "The project folder is no longer present at \(path). Refresh the project list."
        }
    }
}
