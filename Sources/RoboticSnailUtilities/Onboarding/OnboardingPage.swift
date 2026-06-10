import SwiftUI

public struct OnboardingPage: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let titleSymbol: String?
    public let tint: Color
    public let features: [OnboardingFeature]

    /// - Parameter id: Stable identity for the page; defaults to `title`.
    public init(
        id: String? = nil,
        title: String,
        titleSymbol: String? = nil,
        tint: Color,
        features: [OnboardingFeature]
    ) {
        self.id = id ?? title
        self.title = title
        self.titleSymbol = titleSymbol
        self.tint = tint
        self.features = features
    }
}
