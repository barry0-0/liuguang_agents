enum TerminalEngine: String, CaseIterable, Codable, Identifiable {
    case swiftTerm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .swiftTerm: "SwiftTerm"
        }
    }
}
