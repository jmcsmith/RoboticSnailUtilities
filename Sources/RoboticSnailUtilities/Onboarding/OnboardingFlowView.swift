import SwiftUI

public struct OnboardingFlowView: View {
    @Binding private var isCompleted: Bool
    @State private var selectedPage = 0

    private let pages: [OnboardingPage]
    private let continueButtonTitle: String
    private let completionButtonTitle: String
    private let onComplete: (() -> Void)?

    public init(
        isCompleted: Binding<Bool>,
        pages: [OnboardingPage],
        continueButtonTitle: String = "Continue",
        completionButtonTitle: String = "Get Started"
    ) {
        self._isCompleted = isCompleted
        self.pages = pages
        self.continueButtonTitle = continueButtonTitle
        self.completionButtonTitle = completionButtonTitle
        self.onComplete = nil
    }

    public init(
        pages: [OnboardingPage],
        continueButtonTitle: String = "Continue",
        completionButtonTitle: String = "Get Started",
        onComplete: @escaping () -> Void
    ) {
        self._isCompleted = .constant(false)
        self.pages = pages
        self.continueButtonTitle = continueButtonTitle
        self.completionButtonTitle = completionButtonTitle
        self.onComplete = onComplete
    }

    public var body: some View {
        Group {
            if pages.isEmpty {
                EmptyOnboardingStateView(buttonTitle: completionButtonTitle, complete: complete)
                    .padding(22)
            } else {
                VStack(spacing: 0) {
                    TabView(selection: $selectedPage) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            OnboardingPageCardView(page: page)
                                .tag(index)
                                .padding(.horizontal, 22)
                                .padding(.top, 56)
                                .padding(.bottom, 12)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)

                    OnboardingFlowFooterView(
                        selectedPage: $selectedPage,
                        pageCount: pages.count,
                        tint: pages[selectedPage].tint,
                        continueButtonTitle: continueButtonTitle,
                        completionButtonTitle: completionButtonTitle,
                        onComplete: complete
                    )
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func complete() {
        isCompleted = true
        onComplete?()
    }
}

private struct EmptyOnboardingStateView: View {
    let buttonTitle: String
    let complete: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("No onboarding pages configured.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(buttonTitle, action: complete)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingFlowView(
        isCompleted: .constant(false),
        pages: [
            OnboardingPage(
                title: "Welcome",
                tint: .blue,
                features: [
                    OnboardingFeature(icon: "sparkles", title: "Feature One", message: "Describe the first feature."),
                    OnboardingFeature(icon: "star", title: "Feature Two", message: "Describe the second feature.")
                ]
            )
        ]
    )
}
