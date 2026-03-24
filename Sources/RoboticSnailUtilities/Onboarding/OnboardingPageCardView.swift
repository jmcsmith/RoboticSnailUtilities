import SwiftUI

struct OnboardingPageCardView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if let symbol = page.titleSymbol {
                    Image(systemName: symbol)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.yellow)
                }

                Text(page.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.primary)
            }
            .padding(.bottom, 24)

            VStack(alignment: .leading, spacing: 18) {
                ForEach(page.features) { feature in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: feature.icon)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(page.tint)
                            .frame(width: 24)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(feature.title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(feature.message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
