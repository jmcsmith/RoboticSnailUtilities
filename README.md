# RoboticSnailUtilities

SwiftUI-focused utilities for iOS apps, distributed as a Swift Package.

## Requirements

- iOS 18.0+ (as declared in `Package.swift`)
- Swift tools version 6.0+ (the package builds in Swift 6 language mode)

## Installation (Swift Package Manager)

1. In Xcode, choose `File > Add Packages...`
2. Enter this package repository URL
3. Add the `RoboticSnailUtilities` library product to your target

## Included Components

### App Icon Picker

Reusable SwiftUI views/models for selecting alternate app icons.

- `AppIconOption`: model for title/subtitle, preview asset names, and alternate icon name
- `AppIconPicker`: section container that renders available options
- `AppIconRow`: row UI that applies the icon using `UIApplication.setAlternateIconName`

```swift
@State private var selectedIconName: String? = UIApplication.shared.alternateIconName

let options: [AppIconOption] = [
    AppIconOption(title: "Default", lightPreview: "AppIconPreview", alternateIconName: nil),
    AppIconOption(
        title: "Green",
        subtitle: "High contrast",
        lightPreview: "AppIconGreenLight",
        darkPreview: "AppIconGreenDark",
        monoPreview: "AppIconGreenMono",
        alternateIconName: "AppIconGreen"
    )
]

Form {
    AppIconPicker(
        selectedIconName: $selectedIconName,
        options: options,
        sectionName: "App Icon"
    )
}
```

Alternate icons must be declared in your app Info.plist (`CFBundleIcons`).

### Onboarding Flow

Data-driven onboarding UI with paged content, progress indicator, and customizable button titles.

- `OnboardingPage`: page model (title, optional SF Symbol, tint, features)
- `OnboardingFeature`: feature row model (icon, title, message)
- `OnboardingFlowView`: complete flow container

```swift
@State private var isOnboardingCompleted = false

let pages = [
    OnboardingPage(
        title: "Welcome",
        titleSymbol: "sparkles",
        tint: .blue,
        features: [
            OnboardingFeature(
                icon: "checkmark.circle.fill",
                title: "Fast setup",
                message: "Get started in just a few taps."
            ),
            OnboardingFeature(
                icon: "tray.full.fill",
                title: "Everything in one place",
                message: "Keep your important tools and info together."
            )
        ]
    )
]

OnboardingFlowView(
    isCompleted: $isOnboardingCompleted,
    pages: pages,
    continueButtonTitle: "Next",
    completionButtonTitle: "Get Started"
)
```

You can also use the callback-based initializer:

```swift
OnboardingFlowView(pages: pages) {
    print("Onboarding completed")
}
```

### Support Links Sections

Prebuilt settings-style sections for social/about links, optional review button, and version/build display.

- `SocialLinkItem`: model for social row title, image asset, and URL
- `AboutLinkItem`: model for labeled system-image row with tint and URL
- `SupportLinksSections`: view that renders both sections

```swift
SupportLinksSections(
    socialLinks: [
        SocialLinkItem(title: "Bluesky", imageName: "bluesky", url: URL(string: "https://bsky.app"))
    ],
    aboutLinks: [
        AboutLinkItem(title: "Privacy Policy", systemImageName: "lock.doc.fill", tint: .blue, url: URL(string: "https://example.com/privacy"))
    ],
    reviewButtonTitle: "Rate the App",
    onRequestReview: {
        // Trigger your in-app review request flow here.
    },
    version: "1.2.0",
    build: "120"
)
```

### Debug Border

Debug-only border overlay for layout inspection:

```swift
Text("Hello")
    .debugBorder(color: .blue)
```

### Extensions

The package also includes convenience extensions for:

- `TextField.editingStyle(if:)` — rounded-border look that keeps the field's identity (and keyboard) stable when toggled
- `View.isHidden(_:remove:)`
- `NSManagedObjectContext.saveIfNeeded()`
- `Array.halves()` and `Sequence.unique()`
- `Binding.withDefault(_:)` — bridge an optional binding to a non-optional one
- `Date.dayOfWeek()`
- `Float.clean`
- `Double.asString(style:)`
- `Color(hex:)` (supports `RGB`, `RRGGBB`, and `RRGGBBAA`) and `Color.toHex()`
- `UIImage.fixOrientation()`

### Localization note

Built-in strings ("Social", "About", "Version", "Build", "Continue", "Get Started", and the onboarding accessibility labels) are `LocalizedStringKey`s resolved against your app's main bundle, so you can localize them by adding those keys to your app's strings catalog — or pass your own strings through the corresponding parameters.
