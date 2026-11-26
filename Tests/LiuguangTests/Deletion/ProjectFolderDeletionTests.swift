import Foundation
import Testing

@testable import Liuguang

struct ProjectFolderDeletionTests {
    @Test func movesOnlyRealDirectoriesToTheTrash() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let project = root.appendingPathComponent("project")
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        try Data("keep".utf8).write(to: project.appendingPathComponent("source.txt"))

        var trashed: [URL] = []
        var deletion = ProjectFolderDeletion()
        deletion.moveToTrash = { url in
            trashed.append(url)
            try FileManager.default.moveItem(at: url, to: root.appendingPathComponent("trashed-project"))
        }

        #expect(try deletion.moveToTrash([project.path]) == [project.path])
        #expect(trashed == [project])
        #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("trashed-project/source.txt").path))
        #expect(!FileManager.default.fileExists(atPath: project.path))
    }

    @Test func refusesAFileInsteadOfAProjectFolder() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let file = root.appendingPathComponent("not-a-folder.txt")
        try Data("file".utf8).write(to: file)

        var deletion = ProjectFolderDeletion()
        deletion.moveToTrash = { _ in Issue.record("a file must not be trashed") }

        #expect(throws: ProjectFolderDeletionError.folderMissing(file.path)) {
            try deletion.moveToTrash([file.path])
        }
    }
}
