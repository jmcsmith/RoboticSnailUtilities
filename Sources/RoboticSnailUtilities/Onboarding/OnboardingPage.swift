import SwiftUI

public struct OnboardingPage: Identifiable {
    public let id: UUID
    public let title: String
    public let titleSymbol: String?
    public let tint: Color
    public let features: [OnboardingFeature]

    public init(
        id: UUID = UUID(),
        title: String,
        titleSymbol: String? = nil,
        tint: Color,
        features: [OnboardingFeature]
    ) {
        self.id = id
        self.title = title
        self.titleSymbol = titleSymbol
        self.tint = tint
        self.features = features
    }
}
