import SwiftUI

@MainActor
public struct CustomizedAboutDefaultContent<Icon: View, AppCard: View, Footer: View>: View {
    private let context: CustomizedAboutContext
    private let strings: CustomizedAboutStrings
    private let icon: () -> Icon
    private let appCard: (AppStoreApplication) -> AppCard
    private let footer: () -> Footer

    public init(
        context: CustomizedAboutContext,
        strings: CustomizedAboutStrings,
        @ViewBuilder icon: @escaping () -> Icon,
        @ViewBuilder appCard: @escaping (AppStoreApplication) -> AppCard,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.context = context
        self.strings = strings
        self.icon = icon
        self.appCard = appCard
        self.footer = footer
    }

    public init(
        context: CustomizedAboutContext,
        strings: CustomizedAboutStrings,
        @ViewBuilder icon: @escaping () -> Icon
    ) where AppCard == CustomizedAboutAppCard, Footer == EmptyView {
        self.init(
            context: context,
            strings: strings,
            icon: icon,
            appCard: { CustomizedAboutAppCard(application: $0, strings: strings) },
            footer: { EmptyView() }
        )
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                icon()

                Text(context.configuration.metadata.name)
                    .font(.title)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Text(versionDescription)
                    if let copyright = context.configuration.metadata.copyright {
                        Text(copyright)
                    }
                }
                .font(.callout)
                .multilineTextAlignment(.center)

                if let website = context.configuration.developerWebsite {
                    Link(strings.developerWebsite, destination: website)
                }

                if !context.configuration.appStoreIDs.isEmpty {
                    applicationsSection
                }

                if let support = context.configuration.supportWebsite {
                    Link(strings.support, destination: support)
                }

                footer()
            }
            .padding()
            .frame(maxWidth: 440)
            .frame(maxWidth: .infinity)
        }
    }

    private var versionDescription: String {
        "\(strings.version) \(context.configuration.metadata.version) (\(context.configuration.metadata.build))"
    }

    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strings.moreApps)
                .font(.headline)

            switch context.appsState {
            case .idle, .loading:
                ProgressView(strings.loadingApps)
                    .frame(maxWidth: .infinity, minHeight: 92)
            case let .loaded(applications):
                if applications.isEmpty {
                    unavailableContent
                } else {
                    CustomizedAboutAppsGrid(
                        applications: applications,
                        layout: context.configuration.appsLayout,
                        content: appCard
                    )
                }
            case .failed:
                unavailableContent
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var unavailableContent: some View {
        VStack(spacing: 8) {
            Text(strings.appsUnavailable)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(strings.retry, action: context.reload)
        }
        .frame(maxWidth: .infinity, minHeight: 92)
    }
}

@MainActor
public struct CustomizedAboutAppsGrid<Content: View>: View {
    private let applications: [AppStoreApplication]
    private let layout: CustomizedAboutAppsLayout
    private let content: (AppStoreApplication) -> Content

    public init(
        applications: [AppStoreApplication],
        layout: CustomizedAboutAppsLayout,
        @ViewBuilder content: @escaping (AppStoreApplication) -> Content
    ) {
        self.applications = applications
        self.layout = layout
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(layout.groups(for: applications).enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row) { application in
                        content(application)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

@MainActor
public struct CustomizedAboutAppCard: View {
    private let application: AppStoreApplication
    private let strings: CustomizedAboutStrings

    public init(application: AppStoreApplication, strings: CustomizedAboutStrings) {
        self.application = application
        self.strings = strings
    }

    public var body: some View {
        Link(destination: application.storeURL) {
            VStack(spacing: 6) {
                AsyncImage(url: application.artworkURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        Image(systemName: "app.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(application.name)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 92)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            String(format: strings.appStoreAccessibilityFormat, application.name)
        )
    }
}
