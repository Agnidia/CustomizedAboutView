import Foundation

public struct CustomizedAboutConfiguration: Sendable {
    public var metadata: CustomizedAboutMetadata
    public var appStoreIDs: [Int]
    public var storefront: String?
    public var appsLayout: CustomizedAboutAppsLayout
    public var developerWebsite: URL?
    public var supportWebsite: URL?

    public init(
        metadata: CustomizedAboutMetadata = .init(),
        appStoreIDs: [Int] = [],
        storefront: String? = nil,
        appsLayout: CustomizedAboutAppsLayout = .oneByThree,
        developerWebsite: URL? = nil,
        supportWebsite: URL? = nil
    ) {
        self.metadata = metadata
        self.appStoreIDs = appStoreIDs
        self.storefront = storefront
        self.appsLayout = appsLayout
        self.developerWebsite = developerWebsite
        self.supportWebsite = supportWebsite
    }
}
