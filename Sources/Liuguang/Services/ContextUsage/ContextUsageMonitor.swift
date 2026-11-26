import Foundation

/// Keeps one terminal tab's context usage current, by reading the session's file again after a while.
@MainActor
final class ContextUsageMonitor {
    private let conversation: Conversation?
    private var task: Task<Void, Never>?
    private let onChange: @MainActor (ContextUsage?) -> Void

    init(conversation: Conversation?, onChange: @MainActor @escaping (ContextUsage?) -> Void) {
        self.conversation = conversation
        self.onChange = onChange
    }

    func start() {
        guard task == nil else { return }
        refresh()
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollInterval)
                guard let self else { return }
                self.refresh()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    func refresh() {
        onChange(ContextUsageReader.read(conversation: conversation))
    }

    private static let pollInterval = Duration.seconds(2)
}
