# Getting Started

Create an about screen with bundle metadata, related applications, and external links.

## Add the Package

Add `https://github.com/Agnidia/CustomizedAboutView.git` as a Swift Package dependency. Import `CustomizedAboutView` and `SwiftUI` in the file that presents the screen.

## Present the Default Content

The default metadata initializer reads the display name, version, build, bundle identifier, and copyright from the main bundle.

```swift
import CustomizedAboutView
import SwiftUI

struct AboutScreen: View {
    var body: some View {
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
    }
}
```

## Configure a macOS Window

Apply content-based resizability to the scene. The default content uses a minimum size of 220 × 330 points and grows with its content.

```swift
Window("About", id: "about") {
    AboutScreen()
}
.windowResizability(.contentSize)
```

## Replace the Presentation

Use the content initializer when the complete layout must match the host application.

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

Inject an ``AppStoreLookupClient`` to test loading behavior without a network request.
