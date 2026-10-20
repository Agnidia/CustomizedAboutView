@testable import CustomizedAboutView
import Foundation
import Testing

@Suite("CustomizedAboutView")
struct CustomizedAboutViewTests {
    @Test("The automatic layout uses at most two rows", arguments: [
        (1, [[1]]),
        (2, [[1, 2]]),
        (3, [[1, 2, 3]]),
        (4, [[1, 2], [3, 4]]),
        (5, [[1, 2, 3], [4, 5]]),
        (6, [[1, 2, 3], [4, 5, 6]]),
    ])
    func automaticLayout(argument: (Int, [[Int]])) {
        let (applicationCount, expectedGroups) = argument
        let applications = Array(1 ... applicationCount)

        #expect(CustomizedAboutAppsLayout.automatic.groups(for: applications) == expectedGroups)
    }

    @Test("The lookup client supports dependency injection")
    func injectedLookupClient() async throws {
        let expectedURL = try #require(URL(string: "https://apps.apple.com/app/id1"))
        let client = AppStoreLookupClient { ids, storefront in
            #expect(ids == [1])
            #expect(storefront == "ua")
            return [AppStoreApplication(id: 1, name: "Example", storeURL: expectedURL)]
        }

        let applications = try await client.applications(ids: [1], storefront: "ua")
        #expect(applications.map(\.id) == [1])
    }

    @Test("Explicit metadata preserves caller values")
    func explicitMetadata() {
        let metadata = CustomizedAboutMetadata(
            name: "Example",
            version: "1.2.3",
            build: "42",
            bundleIdentifier: "com.example.app",
            copyright: "© Example"
        )

        #expect(metadata.name == "Example")
        #expect(metadata.version == "1.2.3")
        #expect(metadata.build == "42")
        #expect(metadata.bundleIdentifier == "com.example.app")
        #expect(metadata.copyright == "© Example")
    }
}
