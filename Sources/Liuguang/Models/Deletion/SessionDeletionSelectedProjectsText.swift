import Foundation

extension SessionDeletionConfirmationText {
    static func selectedProjectsRemovalButtonTitle(
        projectCount: Int,
        plan: SessionDeletionPlan,
        language: AppInterfaceLanguage = AppLocalization.developmentLanguage
    ) -> String {
        let count = plan.deletableConversations.count
        return AppLocalization.string(
            count == 1
                ? "Remove \(projectCount) projects and delete 1 session"
                : "Remove \(projectCount) projects and delete \(count) sessions",
            language: language
        )
    }

    static func message(
        forRemovingSelectedProjectsAt locations: [ProjectLocation],
        plan: SessionDeletionPlan,
        language: AppInterfaceLanguage = AppLocalization.developmentLanguage
    ) -> String {
        let sentences: [String?] =
            [
                AppLocalization.string(
                    "This affects all tools in \(locations.count) projects, including sessions hidden by the current filter.",
                    language: language),
                cliEndingSentence(for: plan, language: language),
                AppLocalization.string(
                    "The projects are removed from 流光. Their saved sessions are deleted from their CLI storage. Folders on disk are not changed.",
                    language: language
                ),
            ]
        return sentences.compactMap { $0 }.joined(separator: " ")
    }
}
