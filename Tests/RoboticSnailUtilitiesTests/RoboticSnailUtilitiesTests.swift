import Testing
import SwiftUI
import UIKit
@testable import RoboticSnailUtilities

@Suite struct CollectionUtilityTests {
    @Test(arguments: [
        ([Int](), [Int](), [Int]()),
        ([1], [], [1]),
        ([1, 2, 3], [1], [2, 3]),
        ([1, 2, 3, 4], [1, 2], [3, 4]),
    ])
    func halves(input: [Int], expectedLeft: [Int], expectedRight: [Int]) {
        let (left, right) = input.halves()
        #expect(left == expectedLeft)
        #expect(right == expectedRight)
    }

    @Test func uniquePreservesFirstSeenOrder() {
        #expect([1, 2, 1, 3, 2, 1].unique() == [1, 2, 3])
        #expect([Int]().unique() == [])
        #expect(["a", "A", "a"].unique() == ["a", "A"])
    }
}

@Suite struct ColorHexTests {
    @Test func sixDigitRoundTrip() {
        #expect(Color(hex: "336699")?.toHex() == "336699")
        #expect(Color(hex: "#336699")?.toHex() == "336699")
    }

    @Test func eightDigitKeepsAlpha() {
        #expect(Color(hex: "336699FF")?.toHex() == "336699")
        #expect(Color(hex: "33669980")?.toHex() == "33669980")
    }

    @Test func threeDigitShorthandExpands() {
        #expect(Color(hex: "369")?.toHex() == "336699")
        #expect(Color(hex: "FFF")?.toHex() == "FFFFFF")
    }

    @Test(arguments: ["", "12345", "1234567", "GGHHII", "#"])
    func invalidInputReturnsNil(hex: String) {
        #expect(Color(hex: hex) == nil)
    }

    @Test func grayscaleColorsConvertToSRGB() {
        // Regression: grayscale CGColors have 2 components and used to return nil.
        #expect(Color.white.toHex() == "FFFFFF")
        #expect(Color.black.toHex() == "000000")
    }
}

@Suite struct FormattingTests {
    @Test func cleanDropsTrailingZeroFraction() {
        #expect(Float(2.0).clean == "2")
        #expect(Float(-3.0).clean == "-3")
        #expect(Float(2.5).clean == "2.5")
    }

    @Test func asStringFormatsDuration() {
        let formatted = 3661.0.asString(style: .positional)
        #expect(!formatted.isEmpty)
        #expect(formatted.contains(":"))
    }

    @Test func dayOfWeekIsDistinctAcrossAWeek() {
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        let names = (0..<7).map { start.addingTimeInterval(Double($0) * 86_400).dayOfWeek() }
        #expect(names.allSatisfy { !$0.isEmpty })
        #expect(Set(names).count == 7)
    }
}

@Suite struct BindingDefaultTests {
    final class ValueBox<T>: @unchecked Sendable {
        var value: T
        init(_ value: T) { self.value = value }
    }

    @Test func withDefaultSubstitutesAndWritesThrough() {
        let box = ValueBox<Int?>(nil)
        let base = Binding<Int?>(
            get: { box.value },
            set: { box.value = $0 }
        )

        let bound = base.withDefault(5)
        #expect(bound.wrappedValue == 5)

        bound.wrappedValue = 7
        #expect(box.value == 7)
        #expect(bound.wrappedValue == 7)
    }
}

@Suite struct ModelIdentityTests {
    @Test func appIconOptionIdentityIsStableAcrossInstances() {
        let first = AppIconOption(title: "Green", lightPreview: "GreenLight", alternateIconName: "AppIconGreen")
        let second = AppIconOption(title: "Green", lightPreview: "GreenLight", alternateIconName: "AppIconGreen")
        #expect(first.id == second.id)
        #expect(first == second)

        let primary = AppIconOption(title: "Default", lightPreview: "DefaultLight")
        #expect(primary.id == "Default")
    }

    @Test func onboardingModelsDeriveStableIdentity() {
        #expect(OnboardingPage(title: "Welcome", tint: .blue, features: []).id == "Welcome")
        #expect(OnboardingPage(id: "intro", title: "Welcome", tint: .blue, features: []).id == "intro")

        let feature = OnboardingFeature(icon: "star", title: "Fast", message: "Quick setup.")
        let again = OnboardingFeature(icon: "star", title: "Fast", message: "Quick setup.")
        #expect(feature.id == again.id)
    }

    @Test func linkItemIdentityIncludesURL() {
        let url = URL(string: "https://example.com")!
        let other = URL(string: "https://example.org")!
        let a = SocialLinkItem(title: "Site", imageName: "globe", url: url)
        let b = SocialLinkItem(title: "Site", imageName: "globe", url: other)
        #expect(a.id != b.id)
        #expect(SocialLinkItem(title: "Site", imageName: "globe", url: nil).id == "Site")
    }
}

@Suite struct ImageOrientationTests {
    @Test func fixOrientationNormalizesToUp() {
        let source = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 2)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 2))
        }
        let rotated = UIImage(cgImage: source.cgImage!, scale: 1, orientation: .left)

        let fixed = rotated.fixOrientation()
        #expect(fixed.imageOrientation == .up)
        #expect(fixed.size == rotated.size)
    }

    @Test func fixOrientationHandlesEmptyImage() {
        let empty = UIImage()
        #expect(empty.fixOrientation() === empty)
    }
}
