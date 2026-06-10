# AGENTS.md — RoboticSnailUtilities

## What this is

A dependency-free Swift Package of SwiftUI utilities for iOS apps: an alternate app-icon picker, a data-driven onboarding flow, settings-style support/social link sections, a debug border modifier, and assorted small extensions (`Binding`, `Color` hex, collections, formatting, `UIImage`, CoreData).

## Constraints

- **iOS 18.0 minimum, Swift 6 language mode** (swift-tools-version 6.0). All code must build warning-free with strict concurrency — public models are `Sendable`, UI types follow SwiftUI's `@MainActor` isolation.
- **No external dependencies.** Keep it that way.
- **Public API stability matters.** This package is consumed by multiple apps. Prefer `@available(*, deprecated, renamed:)` shims over breaking removals.
- **Identity must be stable.** Model `id`s are derived from content (not `UUID()` at init) so consumers can rebuild model arrays inside view bodies without breaking `ForEach` diffing. Preserve this property in new models.
- Prefer modern APIs: `@Observable` over `ObservableObject`, `foregroundStyle` over `foregroundColor`, `clipShape(.rect(cornerRadius:))` over `cornerRadius`, FormatStyle over allocating formatters, async/await over completion handlers.

## Build & test (CLI)

The package is iOS-only (`import UIKit`), so plain `swift build` on macOS fails — use xcodebuild:

```bash
# Build
xcodebuild -scheme RoboticSnailUtilities -destination 'generic/platform=iOS Simulator' build

# Test (Swift Testing suites)
xcodebuild -scheme RoboticSnailUtilities -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Layout

- `Sources/RoboticSnailUtilities/AppIconPicker/` — `AppIconOption` (model), `AppIconPicker` (section), `AppIconRow` (row + `setAlternateIconName` call)
- `Sources/RoboticSnailUtilities/Onboarding/` — `OnboardingPage`/`OnboardingFeature` (models), `OnboardingFlowView` (container), footer + card views (internal)
- `Sources/RoboticSnailUtilities/SupportLinksSections.swift` — link-section models + view
- Remaining root files — one extension domain per file (`Color+Hex.swift`, `Binding+Defaults.swift`, etc.). Add new extensions to the matching file or create a new domain file; don't recreate a grab-bag.
- `Tests/RoboticSnailUtilitiesTests/` — Swift Testing (`@Test`/`#expect`), not XCTest. Pure helpers should have tests; views are not snapshot-tested.

## Conventions

- User-facing default strings are English `LocalizedStringKey`s resolved in the consuming app's main bundle (documented in README). Keep new user-facing defaults overridable via init parameters.
- Accessibility is part of done: decorative images use `Image(decorative:)` or `.accessibilityHidden(true)`, selected states carry `.isSelected`, custom controls get labels/values/adjustable actions, sizes that sit next to text use `@ScaledMetric`.
- `CODE_AUDIT.md` is a point-in-time audit snapshot, not a living document.
