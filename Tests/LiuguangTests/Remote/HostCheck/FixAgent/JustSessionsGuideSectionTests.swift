import Foundation
import Testing

@testable import Liuguang

struct LiuguangGuideSectionTests {
    @Test(arguments: LiuguangGuideSection.all)
    func everySectionIsInTheGuidesAndShipsWithTheApp(_ section: LiuguangGuideSection) throws {
        let guide = try RepositoryFiles.contents(of: "docs/guides/\(section.fileName)")
        let repositoryText = try #require(LiuguangGuideText.section(headed: section.heading, in: guide))
        #expect(LiuguangGuideText.text(of: section) == repositoryText)
    }

    /// The guides link to these sections themselves, by the anchors GitHub gives their headings.
    @Test func anchorsAreTheOnesTheGuidesLinkTo() throws {
        let guide = try RepositoryFiles.contents(of: "docs/guides/session-management.md")
        for section in [LiuguangGuideSection.whenSomethingFailsOnSSHHost, .shellStartupOnSSHHosts, .hostsThatAskForPassword] {
            #expect(guide.contains("](#\(section.anchor))"), "\(section.anchor)")
        }
        #expect(guide.contains("](session-storage.md#\(LiuguangGuideSection.terminalPersistence.anchor))"))
    }

    @Test func aSectionEndsAtTheNextHeadingOfItsLevelAndSkipsCodeBlocks() {
        let markdown = """
            ## SSH hosts
            Intro.
            ### Shell startup
            Line one.
            ```sh
            # not a heading
            ```
            #### Detail
            More.
            ### Next
            Other.
            """
        #expect(
            LiuguangGuideText.section(headed: "Shell startup", in: markdown)
                == "### Shell startup\nLine one.\n```sh\n# not a heading\n```\n#### Detail\nMore.")
        #expect(LiuguangGuideText.section(headed: "Missing", in: markdown) == nil)
    }

    @Test func linksGoToTheReleasesGuidesOrToMainForADevelopmentBuild() {
        #expect(LiuguangGuideText.gitReference(forAppVersion: "1.2.11") == "v1.2.11")
        #expect(LiuguangGuideText.gitReference(forAppVersion: "1.2.11-3-gabc1234") == "main")
        #expect(LiuguangGuideText.gitReference(forAppVersion: "1.2") == "main")
        #expect(
            LiuguangGuideSection.whenSomethingFailsOnSSHHost.link(gitReference: "v1.2.11").absoluteString
                == "https://github.com/yangzichao/Liuguang/blob/v1.2.11/docs/guides/session-management.md#when-something-fails-on-an-ssh-host"
        )
    }

    @Test func theSectionsAboutAReportFollowItsProblemsAndWarnings() {
        let report = HostCheckReport(
            host: "devbox",
            checkedAt: .now,
            thisMacSummary: "",
            findings: [
                HostCheckFinding(id: .tmux, status: .problem, title: "tmux", summary: ""),
                HostCheckFinding(id: .cli(.claude), status: .warning, title: "Claude Code", summary: ""),
                HostCheckFinding(id: .rsync, status: .passed, title: "rsync", summary: ""),
            ]
        )
        #expect(
            LiuguangGuideSection.sections(about: report)
                == [.whenSomethingFailsOnSSHHost, .terminalPersistence, .cliLaunchAndDiscovery])
    }
}
