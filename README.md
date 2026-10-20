# CustomizedAboutView

`CustomizedAboutView` is a customizable SwiftUI about screen for every Apple platform. It reads localized application metadata from a bundle and can load related applications from the App Store.

## Platforms

| Platform | Minimum version |
|---|---:|
| iOS and Mac Catalyst | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

## Installation

Add `https://github.com/Agnidia/CustomizedAboutView.git` as a Swift Package dependency.

## Default content

```swift
import CustomizedAboutView
import SwiftUI

CustomizedAboutView(
    configuration: .init(
        appStoreIDs: [1_583_462_846, 6_471_902_188, 1_661_688_468],
        appsLayout: .oneByThree,
        developerWebsite: URL(string: "https://example.com"),
        supportWebsite: URL(string: "https://example.com/support")
    )
) {
    Image("AboutIcon")
        .resizable()
        .scaledToFit()
        .frame(width: 96, height: 96)
}
```

The default metadata initializer reads these localized bundle values:

- `CFBundleDisplayName`, with `CFBundleName` as a fallback
- `CFBundleShortVersionString`
- `CFBundleVersion`
- `NSHumanReadableCopyright`

## Application layouts

| Preset | Rows | Capacity before repeating the final row |
|---|---|---:|
| `.oneByOne` | `1` | 1 |
| `.oneByTwo` | `2` | 2 |
| `.oneByThree` | `3` | 3 |
| `.oneByThreePlusTwoByOne` | `3 + 1 + 1` | 5 |
| `.oneByThreePlusTwoByTwo` | `3 + 2 + 2` | 7 |
| `.oneByThreePlusTwoByThree` | `3 + 3 + 3` | 9 |

Create any other layout with `CustomizedAboutAppsLayout(rows:)`.

## Full customization

Replace the complete presentation while retaining bundle metadata and App Store loading:

```swift
CustomizedAboutView(configuration: configuration) { context, strings in
    VStack {
        Text(context.configuration.metadata.name)

        if case let .loaded(applications) = context.appsState {
            ForEach(applications) { application in
                Link(application.name, destination: application.storeURL)
            }
        }

        Button(strings.retry, action: context.reload)
    }
}
```

The default English and Ukrainian localizations follow the SwiftUI environment locale. Pass `CustomizedAboutStrings` to provide any localization or wording.

The App Store client is injectable. Tests and offline applications can supply a custom `AppStoreLookupClient`.

## License

CustomizedAboutView is available under the MIT license.
