import Foundation

public struct CustomizedAboutMetadata: Hashable, Sendable {
    public let name: String
    public let version: String
    public let build: String
    public let bundleIdentifier: String?
    public let copyright: String?

    public init(
        name: String,
        version: String,
        build: String,
        bundleIdentifier: String? = nil,
        copyright: String? = nil
    ) {
        self.name = name
        self.version = version
        self.build = build
        self.bundleIdentifier = bundleIdentifier
        self.copyright = copyright
    }

    public init(bundle: Bundle = .main, fallbackName: String = "Application") {
        let localized = bundle.localizedInfoDictionary ?? [:]
        let unlocalized = bundle.infoDictionary ?? [:]

        name = Self.string(
            keys: ["CFBundleDisplayName", "CFBundleName"],
            localized: localized,
            unlocalized: unlocalized
        ) ?? fallbackName
        version = Self.string(
            keys: ["CFBundleShortVersionString"],
            localized: localized,
            unlocalized: unlocalized
        ) ?? "—"
        build = Self.string(
            keys: ["CFBundleVersion"],
            localized: localized,
            unlocalized: unlocalized
        ) ?? "—"
        bundleIdentifier = bundle.bundleIdentifier
        copyright = Self.string(
            keys: ["NSHumanReadableCopyright"],
            localized: localized,
            unlocalized: unlocalized
        )
    }

    private static func string(
        keys: [String],
        localized: [String: Any],
        unlocalized: [String: Any]
    ) -> String? {
        for key in keys {
            if let value = localized[key] as? String, !value.isEmpty {
                return value
            }
            if let value = unlocalized[key] as? String, !value.isEmpty {
                return value
            }
        }
        return nil
    }
}
