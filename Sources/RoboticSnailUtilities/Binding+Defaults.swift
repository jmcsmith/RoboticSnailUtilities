import SwiftUI

public extension Binding {
    /// Bridges an optional binding to a non-optional one, substituting `defaultValue` while the
    /// wrapped value is `nil`.
    func withDefault<T: Sendable>(_ defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

public extension Binding where Value == String? {
    @available(*, deprecated, renamed: "withDefault(_:)")
    func withDefaultValue(_ fallback: String) -> Binding<String> {
        withDefault(fallback)
    }
}

public extension Binding where Value == Date? {
    @available(*, deprecated, renamed: "withDefault(_:)")
    func withDefaultValue(_ fallback: Date) -> Binding<Date> {
        withDefault(fallback)
    }
}
