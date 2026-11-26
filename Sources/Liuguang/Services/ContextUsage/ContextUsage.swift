import Foundation

/// How much of a CLI's context window one session fills.
///
/// `used` counts the tokens the CLI sends as the prompt of its last request: the fresh input plus whatever it read
/// from the provider's cache. The CLI's output tokens are not part of it, since they leave the window with the
/// answer rather than staying in the next prompt.
struct ContextUsage: Equatable, Sendable {
    let used: Int
    let window: Int?
    /// A CLI that reports only how full its window is, such as Kiro CLI, has no token count of its own.
    let reportedPercent: Double?

    init(used: Int, window: Int?, reportedPercent: Double? = nil) {
        self.used = used
        self.window = window
        self.reportedPercent = reportedPercent
    }

    var percent: Double? {
        if let reportedPercent { return reportedPercent }
        guard let window, window > 0 else { return nil }
        return min(max(Double(used) / Double(window) * 100, 0), 999)
    }

    var label: String {
        guard let percent else { return "\(used.formatted()) tok" }
        guard let window else { return "\(Int(percent))%" }
        return "\(used.formatted()) / \(window.formatted()) · \(Int(percent))%"
    }
}
