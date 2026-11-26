import Foundation

enum AppLinks {
    static let websiteURL = URL(string: "https://barry0-0.github.io/liuguang_agents/")!
    static let userGuideURL = websiteURL.appendingPathComponent("guide.html")
    static let releaseNotesURL = websiteURL.appendingPathComponent("release-notes.html")
    static let userGuideSSHHostsURL = userGuideSection("ssh-hosts")
    static let userGuideSSHShellStartupURL = userGuideSection("ssh-shell-startup")
    static let userGuideTroubleshootingURL = userGuideSection("troubleshooting")
    static let userGuideFeedbackURL = userGuideSection("feedback")
    static let gitHubRepositoryURL = URL(string: "https://github.com/barry0-0/liuguang_agents")!
    static let newGitHubIssueURL = gitHubRepositoryURL.appendingPathComponent("issues/new")
    static let feedbackEmailAddress = "barryphys@gmail.com"

    private static func userGuideSection(_ sectionID: String) -> URL {
        var components = URLComponents(url: userGuideURL, resolvingAgainstBaseURL: false)!
        components.fragment = sectionID
        return components.url!
    }
}
