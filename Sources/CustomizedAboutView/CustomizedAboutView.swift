import SwiftUI

public enum CustomizedAboutAppsState: Equatable, Sendable {
    case idle
    case loading
    case loaded([AppStoreApplication])
    case failed
}

@MainActor
public struct CustomizedAboutContext {
    public let configuration: CustomizedAboutConfiguration
    public let appsState: CustomizedAboutAppsState
    public let reload: () -> Void
}

@MainActor
public struct CustomizedAboutView: View {
    private let configuration: CustomizedAboutConfiguration
    private let client: AppStoreLookupClient
    private let strings: CustomizedAboutStrings?
    private let content: (CustomizedAboutContext, CustomizedAboutStrings) -> AnyView

    @Environment(\.locale) private var locale
    @State private var appsState = CustomizedAboutAppsState.idle
    @State private var reloadID = 0

    public init(
        configuration: CustomizedAboutConfiguration,
        client: AppStoreLookupClient = .live,
        strings: CustomizedAboutStrings? = nil,
        @ViewBuilder content: @escaping (CustomizedAboutContext, CustomizedAboutStrings) -> some View
    ) {
        self.configuration = configuration
        self.client = client
        self.strings = strings
        self.content = { context, resolvedStrings in
            AnyView(content(context, resolvedStrings))
        }
    }

    public init(
        configuration: CustomizedAboutConfiguration,
        client: AppStoreLookupClient = .live,
        strings: CustomizedAboutStrings? = nil,
        @ViewBuilder icon: @escaping () -> some View
    ) {
        self.init(configuration: configuration, client: client, strings: strings) { context, labels in
            CustomizedAboutDefaultContent(context: context, strings: labels, icon: icon)
        }
    }

    public init(
        configuration: CustomizedAboutConfiguration,
        client: AppStoreLookupClient = .live,
        strings: CustomizedAboutStrings? = nil,
        @ViewBuilder icon: @escaping () -> some View,
        @ViewBuilder appCard: @escaping (AppStoreApplication) -> some View,
        @ViewBuilder footer: @escaping () -> some View
    ) {
        self.init(configuration: configuration, client: client, strings: strings) { context, labels in
            CustomizedAboutDefaultContent(
                context: context,
                strings: labels,
                icon: icon,
                appCard: appCard,
                footer: footer
            )
        }
    }

    public var body: some View {
        let resolvedStrings = strings ?? .localized(for: locale)
        content(
            CustomizedAboutContext(
                configuration: configuration,
                appsState: appsState,
                reload: { reloadID += 1 }
            ),
            resolvedStrings
        )
        .task(id: reloadID) {
            await loadApplications()
        }
    }

    private func loadApplications() async {
        guard !configuration.appStoreIDs.isEmpty else {
            appsState = .loaded([])
            return
        }

        appsState = .loading
        do {
            let applications = try await client.applications(
                ids: configuration.appStoreIDs,
                storefront: configuration.storefront
            )
            guard !Task.isCancelled else { return }
            appsState = .loaded(applications)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            appsState = .failed
        }
    }
}
