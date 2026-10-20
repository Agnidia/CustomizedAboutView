@testable import CustomizedAboutView
import Foundation
import Testing

@Suite("CustomizedAboutView")
struct CustomizedAboutViewTests {
    @Test("Layout presets create the requested rows")
    func layoutPresets() {
        #expect(CustomizedAboutAppsLayout.oneByOne.rows == [1])
        #expect(CustomizedAboutAppsLayout.oneByTwo.rows == [2])
        #expect(CustomizedAboutAppsLayout.oneByThree.rows == [3])
        #expect(CustomizedAboutAppsLayout.oneByThreePlusTwoByOne.rows == [3, 1, 1])
        #expect(CustomizedAboutAppsLayout.oneByThreePlusTwoByTwo.rows == [3, 2, 2])
        #expect(CustomizedAboutAppsLayout.oneByThreePlusTwoByThree.rows == [3, 3, 3])
    }

    @Test("The final row pattern repeats for overflow")
    func layoutOverflow() {
        let groups = CustomizedAboutAppsLayout(rows: [3, 2]).groups(for: Array(1 ... 9))
        #expect(groups == [[1, 2, 3], [4, 5], [6, 7], [8, 9]])
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
