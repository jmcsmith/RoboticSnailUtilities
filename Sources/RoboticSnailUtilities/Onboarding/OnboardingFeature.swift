import Foundation

public struct OnboardingFeature: Identifiable, Sendable {
    public let id: String
    public let icon: String
    public let title: String
    public let message: String

    /// - Parameter id: Stable identity for the feature; defaults to a
    ///   combination of `icon` and `title`.
    public init(
        id: String? = nil,
        icon: String,
        title: String,
        message: String
    ) {
        self.id = id ?? "\(icon)|\(title)"
        self.icon = icon
        self.title = title
        self.message = message
    }
}
