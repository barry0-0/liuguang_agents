import ApplicationServices

struct AccessibilityTrustProbe {
    var isProcessTrusted: @Sendable () -> Bool = { AXIsProcessTrusted() }

    func status() -> AppPermissionStatus {
        isProcessTrusted() ? .allowed : .notAllowed
    }

    @MainActor
    func request() -> Bool {
        let promptKey: CFString = "AXTrustedCheckOptionPrompt" as CFString
        return AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
    }
}
