import Foundation

enum AppLocalization {
    /// The packaged app keeps SwiftPM's resource bundle in Contents/Resources. `Bundle.module` never looks there:
    /// it checks only the .app root and the absolute path of the machine that built it, then stops the app.
    static let resourceBundle = packagedResourceBundle(in: .main) ?? .module

    static func packagedResourceBundle(in appBundle: Bundle) -> Bundle? {
        guard let resourceURL = appBundle.resourceURL else { return nil }
        let names = ["Liuguang_Liuguang.bundle", "流光_流光.bundle"]
        for name in names {
            let candidate = resourceURL.appendingPathComponent(name)
            if let bundle = Bundle(url: candidate), bundle.resourcePath != nil {
                return bundle
            }
        }
        return nil
    }
    static var developmentLanguage: AppInterfaceLanguage {
        AppInterfaceLanguage(identifier: resourceBundle.developmentLocalization ?? "en")
    }

    static func string(
        _ value: String.LocalizationValue,
        language: AppInterfaceLanguage? = nil,
        bundle: Bundle = resourceBundle,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> String {
        let locale = locale(language: language, bundle: bundle, preferredLanguages: preferredLanguages)
        // SwiftPM lowercases .lproj names; do not assume filesystem spelling matches a canonical BCP-47 tag.
        let resourceIdentifier =
            bundle.localizations.first {
                AppInterfaceLanguage.canonicalIdentifier($0) == locale.identifier
            } ?? locale.identifier
        let localizedBundle = bundle.url(forResource: resourceIdentifier, withExtension: "lproj").flatMap(Bundle.init(url:)) ?? bundle
        return String(localized: value, bundle: localizedBundle, locale: locale)
    }

    static func string(
        resource: LocalizedStringResource,
        language: AppInterfaceLanguage? = nil,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> String {
        let bundle: Bundle
        switch resource.bundle {
        case .main: bundle = .main
        case .forClass(let resourceClass): bundle = Bundle(for: resourceClass)
        case .atURL(let url): bundle = Bundle(url: url) ?? .main
        @unknown default: bundle = .main
        }
        var localizedResource = resource
        localizedResource.locale = locale(language: language, bundle: bundle, preferredLanguages: preferredLanguages)
        return String(localized: localizedResource)
    }

    private static func locale(
        language: AppInterfaceLanguage?, bundle: Bundle, preferredLanguages: [String]
    ) -> Locale {
        let requestedLanguage =
            language ?? UserDefaults.standard.string(forKey: AppInterfaceLanguage.userDefaultsKey)
            .map { AppInterfaceLanguage(identifier: $0) } ?? .followSystem
        let selectedLanguage =
            AppInterfaceLanguage.choices(availableLocalizations: bundle.localizations).contains(requestedLanguage)
            ? requestedLanguage : .followSystem
        return Locale(
            identifier: selectedLanguage.localizationIdentifier(
                availableLocalizations: bundle.localizations, preferredLanguages: preferredLanguages,
                developmentLocalization: bundle.developmentLocalization ?? "en"
            ))
    }
}
