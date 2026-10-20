import Foundation

/// Configures metadata, related applications, and external links.
public struct CustomizedAboutConfiguration: Sendable {
    public var metadata: CustomizedAboutMetadata
    public var appStoreIDs: [Int]
    public var storefront: String?
    public var developerWebsite: URL?
    public var supportWebsite: URL?
    public var contactWebsite: URL?

    public init(
        metadata: CustomizedAboutMetadata = .init(),
        appStoreIDs: [Int] = .init(),
        storefront: String? = nil,
        developerWebsite: URL? = nil,
        supportWebsite: URL? = nil,
        contactWebsite: URL? = nil
    ) {
        self.metadata = metadata
        self.appStoreIDs = appStoreIDs
        self.storefront = storefront
        self.developerWebsite = developerWebsite
        self.supportWebsite = supportWebsite
        self.contactWebsite = contactWebsite
    }
}
