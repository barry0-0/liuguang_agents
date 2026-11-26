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
                ? "Delete \(projectCount) project folders and 1 session"
                : "Delete \(projectCount) project folders and \(count) sessions",
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
                    "Each project folder on this Mac moves to the Trash with its session files. A session whose CLI still runs ends first.",
                    language: language
                ),
            ]
        return sentences.compactMap { $0 }.joined(separator: " ")
    }
}
