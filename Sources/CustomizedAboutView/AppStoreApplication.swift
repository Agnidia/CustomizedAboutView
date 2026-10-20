import Foundation

public struct AppStoreApplication: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let artworkURL: URL?
    public let storeURL: URL

    public init(id: Int, name: String, artworkURL: URL? = nil, storeURL: URL) {
        self.id = id
        self.name = name
        self.artworkURL = artworkURL
        self.storeURL = storeURL
    }
}

public struct AppStoreLookupClient: Sendable {
    private let lookupOperation: @Sendable ([Int], String?) async throws -> [AppStoreApplication]

    public init(
        lookup: @escaping @Sendable ([Int], String?) async throws -> [AppStoreApplication]
    ) {
        lookupOperation = lookup
    }

    public func applications(ids: [Int], storefront: String? = nil) async throws -> [AppStoreApplication] {
        try await lookupOperation(ids, storefront)
    }

    public static let live = Self { ids, storefront in
        guard !ids.isEmpty else { return [] }

        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [
            URLQueryItem(name: "id", value: ids.map(String.init).joined(separator: ",")),
            URLQueryItem(name: "country", value: normalizedStorefront(storefront)),
        ]
        guard let url = components?.url else {
            throw AppStoreLookupError.invalidRequest
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
              (200 ..< 300).contains(response.statusCode)
        else {
            throw AppStoreLookupError.unsuccessfulResponse
        }

        let responseBody = try JSONDecoder().decode(LookupResponse.self, from: data)
        let applications = responseBody.results.map(\.application)
        let applicationsByID = Dictionary(
            applications.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return ids.compactMap { applicationsByID[$0] }
    }

    private static func normalizedStorefront(_ storefront: String?) -> String {
        let value = storefront ?? Locale.current.region?.identifier ?? "US"
        return value.lowercased()
    }
}

public enum AppStoreLookupError: Error, Equatable, Sendable {
    case invalidRequest
    case unsuccessfulResponse
}

private struct LookupResponse: Decodable {
    let results: [LookupApplication]
}

private struct LookupApplication: Decodable {
    let trackId: Int
    let trackName: String
    let artworkUrl512: URL?
    let artworkUrl100: URL?
    let trackViewUrl: URL

    var application: AppStoreApplication {
        AppStoreApplication(
            id: trackId,
            name: trackName,
            artworkURL: artworkUrl512 ?? artworkUrl100,
            storeURL: trackViewUrl
        )
    }
}
