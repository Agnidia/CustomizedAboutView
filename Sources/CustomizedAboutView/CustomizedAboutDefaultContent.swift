import SwiftUI

/// Provides the standard about-screen presentation.
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

                if context.configuration.supportWebsite != nil
                    || context.configuration.contactWebsite != nil
                {
                    HStack(spacing: 16) {
                        if let support = context.configuration.supportWebsite {
                            Link(strings.support, destination: support)
                        }
                        if let contact = context.configuration.contactWebsite {
                            Link(strings.contact, destination: contact)
                        }
                    }
                }

                footer()
            }
            .padding()
        }
        .customizedAboutContentSize()
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
                    .frame(minHeight: 92)
            case let .loaded(applications):
                if applications.isEmpty {
                    unavailableContent
                } else {
                    CustomizedAboutAppsGrid(
                        applications: applications,
                        content: appCard
                    )
                }
            case .failed:
                unavailableContent
            }
        }
    }

    private var unavailableContent: some View {
        VStack(spacing: 8) {
            Text(strings.appsUnavailable)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(strings.retry, action: context.reload)
        }
        .frame(minHeight: 92)
    }
}

private extension View {
    @ViewBuilder
    func customizedAboutContentSize() -> some View {
        #if os(macOS)
            frame(minWidth: 220, minHeight: 330)
                .fixedSize(horizontal: true, vertical: true)
        #else
            self
        #endif
    }
}

/// Arranges up to six application cards into centered automatic rows.
@MainActor
public struct CustomizedAboutAppsGrid<Content: View>: View {
    private let applications: [AppStoreApplication]
    private let content: (AppStoreApplication) -> Content

    public init(
        applications: [AppStoreApplication],
        @ViewBuilder content: @escaping (AppStoreApplication) -> Content
    ) {
        self.applications = applications
        self.content = content
    }

    public var body: some View {
        let rowCounts = CustomizedAboutAppsLayout.automatic.groups(for: applications).map(\.count)

        CenteredRowsLayout(
            rowCounts: rowCounts,
            cellSize: CGSize(width: 128, height: 92),
            spacing: 8
        ) {
            ForEach(applications) { application in
                content(application)
                    .frame(width: 128, height: 92)
            }
        }
    }
}

private struct CenteredRowsLayout: Layout {
    let rowCounts: [Int]
    let cellSize: CGSize
    let spacing: CGFloat

    func sizeThatFits(
        proposal _: ProposedViewSize,
        subviews _: Subviews,
        cache _: inout ()
    ) -> CGSize {
        guard let maximumColumns = rowCounts.max(), maximumColumns > .zero else {
            return .zero
        }

        return CGSize(
            width: cellSize.width * CGFloat(maximumColumns)
                + spacing * CGFloat(maximumColumns - 1),
            height: cellSize.height * CGFloat(rowCounts.count)
                + spacing * CGFloat(max(.zero, rowCounts.count - 1))
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        guard !rowCounts.isEmpty else {
            return
        }

        var subviewIndex: Int = .zero
        var y = bounds.minY

        for columnCount in rowCounts {
            let rowWidth = cellSize.width * CGFloat(columnCount)
                + spacing * CGFloat(max(.zero, columnCount - 1))
            var x = bounds.midX - rowWidth / 2

            for _ in .zero ..< columnCount where subviewIndex < subviews.count {
                subviews[subviewIndex].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(
                        width: cellSize.width,
                        height: cellSize.height
                    )
                )
                x += cellSize.width + spacing
                subviewIndex += 1
            }

            y += cellSize.height + spacing
        }
    }
}

/// Presents one application as a fixed-size App Store link.
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
            .frame(width: 128, height: 92)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            String(format: strings.appStoreAccessibilityFormat, application.name)
        )
    }
}

private struct ApplicationsLayoutPreview: View {
    let applicationCount: Int

    private var applications: [AppStoreApplication] {
        (1 ... applicationCount).map { index in
            AppStoreApplication(
                id: index,
                name: "Application \(index)",
                storeURL: URL(fileURLWithPath: "/applications/\(index)")
            )
        }
    }

    var body: some View {
        CustomizedAboutDefaultContent(
            context: CustomizedAboutContext(
                configuration: CustomizedAboutConfiguration(
                    metadata: CustomizedAboutMetadata(
                        name: "Example",
                        version: "1.0.0",
                        build: "100",
                        copyright: "© 2026 Company"
                    ),
                    appStoreIDs: applications.map(\.id),
                    developerWebsite: URL(string: "https://example.com"),
                    supportWebsite: URL(string: "https://example.com/support"),
                    contactWebsite: URL(string: "https://example.com/contact")
                ),
                appsState: .loaded(applications),
                reload: {}
            ),
            strings: .localized(for: Locale(identifier: "en"))
        ) {
            Image(systemName: "info.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        }
    }
}

#Preview("1 App") {
    ApplicationsLayoutPreview(applicationCount: 1)
}

#Preview("2 Apps") {
    ApplicationsLayoutPreview(applicationCount: 2)
}

#Preview("3 Apps") {
    ApplicationsLayoutPreview(applicationCount: 3)
}

#Preview("4 Apps — 2 × 2") {
    ApplicationsLayoutPreview(applicationCount: 4)
}

#Preview("5 Apps — 3 + 2") {
    ApplicationsLayoutPreview(applicationCount: 5)
}

#Preview("6 Apps — 3 + 3") {
    ApplicationsLayoutPreview(applicationCount: 6)
}
