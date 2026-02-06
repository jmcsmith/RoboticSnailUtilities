# RoboticSnailUtilities

Lightweight SwiftUI utilities and helpers for iOS apps, packaged as a Swift Package.
## Requirements

- iOS 15.0+
- Swift 5.6+

## Installation (Swift Package Manager)

Add the package to your project in Xcode:

1. File > Add Packages...
2. Enter the repository URL for this package
3. Add the `RoboticSnailUtilities` product to your target

## Features

### App Icon Picker (SwiftUI)

Use a ready-made SwiftUI section + row to allow users to pick alternate app icons.

- `AppIconPicker`: A `Section` that lists available icon options
- `AppIconRow`: Handles selection and calls `UIApplication.shared.setAlternateIconName`
- `AppIconOption`: Model describing light/dark/mono preview assets and the alternate icon name

Example:

```swift
@State private var selectedIconName: String? = UIApplication.shared.alternateIconName

let options: [AppIconOption] = [
    AppIconOption(title: "Default", lightPreview: "AppIconPreview", alternateIconName: nil),
    AppIconOption(title: "Green", lightPreview: "AppIconGreenPreview", alternateIconName: "AppIconGreen")
]

Form {
    AppIconPicker(
        selectedIconName: $selectedIconName,
        options: options,
        sectionName: "App Icon"
    )
}
```

Note: Alternate icons must be declared in your app’s Info.plist under `CFBundleIcons`.

### Debug Border

Debug-only view borders for layout inspection:

```swift
Text("Hello")
    .debugBorder(color: .blue)
```

### Extensions

A collection of small conveniences, including:

- `TextField.editingStyle(if:)`
- `View.isHidden(_:remove:)`
- `NSManagedObjectContext.saveIfNeeded()`
- `Array.halves()` and `Sequence.unique()`
- `Binding` helpers for optional values
- `Date.dayOfWeek()`, `Float.clean`, `Double.asString(style:)`
- `Color(hex:)` and `Color.toHex()`
- `UIImage.fixOrientation()`

### LogStore

A simple OSLog-backed store that can export recent log entries for the current process:

```swift
@StateObject private var logStore = LogStore()

logStore.export()
print(logStore.entries)
```

Includes preconfigured loggers:
- `LogStore.logger`
- `LogStore.info`
- `LogStore.warning`
- `LogStore.errors`

