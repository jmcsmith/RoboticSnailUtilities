import SwiftUI

struct OnboardingFlowFooterView: View {
    @Binding var selectedPage: Int
    let pageCount: Int
    let tint: Color
    let continueButtonTitle: String
    let completionButtonTitle: String
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isLastPage: Bool {
        selectedPage >= pageCount - 1
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index == selectedPage ? Color.primary.opacity(0.95) : Color.secondary.opacity(0.35))
                        .frame(width: index == selectedPage ? 20 : 6, height: 6)
                        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: selectedPage)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Onboarding progress")
            .accessibilityValue("Page \(selectedPage + 1) of \(pageCount)")

            Button(action: advance) {
                Text(isLastPage ? completionButtonTitle : continueButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(
                LinearGradient(
                    colors: [tint.opacity(1.0), tint.opacity(0.78)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule(style: .continuous)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.primary.opacity(0.14), lineWidth: 1)
            )
        }
    }

    private func advance() {
        if isLastPage {
            onComplete()
            return
        }

        if reduceMotion {
            selectedPage += 1
        } else {
            withAnimation(.snappy) {
                selectedPage += 1
            }
        }
    }
}
