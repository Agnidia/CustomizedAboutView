# ``CustomizedAboutView``

Build an adaptable SwiftUI about screen for every Apple platform.

![A six-application about screen](preview-6-apps.png)

## Overview

CustomizedAboutView reads application metadata from a bundle and loads related applications from the App Store. The default content includes an icon, version details, external links, and up to six application cards.

Provide a configuration and an icon to create the default presentation:

```swift
CustomizedAboutView(
    configuration: .init(
        appStoreIDs: [1_583_462_846, 6_471_902_188],
        developerWebsite: URL(string: "https://example.com"),
        supportWebsite: URL(string: "https://example.com/support"),
        contactWebsite: URL(string: "https://example.com/contact")
    )
) {
    Image("AboutIcon")
        .resizable()
        .scaledToFit()
        .frame(width: 96, height: 96)
}
```

The application grid selects one or two rows from the number of loaded applications. Each card uses a fixed 128 × 92 point frame.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:PreviewGallery>
- ``CustomizedAboutView/CustomizedAboutView``
- ``CustomizedAboutConfiguration``
- ``CustomizedAboutMetadata``

### Application Loading

- ``AppStoreApplication``
- ``AppStoreLookupClient``
- ``AppStoreLookupError``
- ``CustomizedAboutAppsState``

### Customization

- ``CustomizedAboutContext``
- ``CustomizedAboutDefaultContent``
- ``CustomizedAboutAppsGrid``
- ``CustomizedAboutAppCard``
- ``CustomizedAboutStrings``
