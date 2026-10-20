import Foundation

/// Contains every user-facing string used by the default content.
public struct CustomizedAboutStrings: Hashable, Sendable {
    public var version: String
    public var developerWebsite: String
    public var moreApps: String
    public var loadingApps: String
    public var appsUnavailable: String
    public var retry: String
    public var support: String
    public var contact: String
    public var appStoreAccessibilityFormat: String

    public init(
        version: String,
        developerWebsite: String,
        moreApps: String,
        loadingApps: String,
        appsUnavailable: String,
        retry: String,
        support: String,
        contact: String = "Contact",
        appStoreAccessibilityFormat: String
    ) {
        self.version = version
        self.developerWebsite = developerWebsite
        self.moreApps = moreApps
        self.loadingApps = loadingApps
        self.appsUnavailable = appsUnavailable
        self.retry = retry
        self.support = support
        self.contact = contact
        self.appStoreAccessibilityFormat = appStoreAccessibilityFormat
    }

    public static func localized(for locale: Locale = .current) -> Self {
        let bundle = localizedBundle(for: locale)
        return Self(
            version: bundle.text("about.version", fallback: "Version"),
            developerWebsite: bundle.text("about.developer_website", fallback: "Developer Website"),
            moreApps: bundle.text("about.more_apps", fallback: "More Apps"),
            loadingApps: bundle.text("about.loading_apps", fallback: "Loading apps…"),
            appsUnavailable: bundle.text(
                "about.apps_unavailable",
                fallback: "App Store information is unavailable."
            ),
            retry: bundle.text("about.retry", fallback: "Retry"),
            support: bundle.text("about.support", fallback: "Support"),
            contact: bundle.text("about.contact", fallback: "Contact"),
            appStoreAccessibilityFormat: bundle.text(
                "about.app_store_accessibility",
                fallback: "View %@ on the App Store"
            )
        )
    }

    private static func localizedBundle(for locale: Locale) -> Bundle {
        let preferences = [locale.identifier, locale.language.languageCode?.identifier].compactMap(\.self)
        guard let localization = Bundle.preferredLocalizations(
            from: Bundle.module.localizations,
            forPreferences: preferences
        ).first,
            let path = Bundle.module.path(forResource: localization, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .module
        }
        return bundle
    }
}

private extension Bundle {
    func text(_ key: String, fallback: String) -> String {
        localizedString(forKey: key, value: fallback, table: nil)
    }
}
