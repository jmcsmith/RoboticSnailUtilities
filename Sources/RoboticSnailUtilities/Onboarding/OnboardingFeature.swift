import Foundation

public struct OnboardingFeature: Identifiable {
    public let id: UUID
    public let icon: String
    public let title: String
    public let message: String

    public init(
        id: UUID = UUID(),
        icon: String,
        title: String,
        message: String
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.message = message
    }
}
