import SwiftUI

public struct SocialLinkItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let imageName: String
    public let url: URL?

    public init(id: String? = nil, title: String, imageName: String, url: URL?) {
        self.id = id ?? title
        self.title = title
        self.imageName = imageName
        self.url = url
    }
}

public struct AboutLinkItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let systemImageName: String
    public let tint: Color
    public let url: URL?

    public init(
        id: String? = nil,
        title: String,
        systemImageName: String = "globe.americas.fill",
        tint: Color = .blue,
        url: URL?
    ) {
        self.id = id ?? title
        self.title = title
        self.systemImageName = systemImageName
        self.tint = tint
        self.url = url
    }
}

public struct SupportLinksSections: View {
    private let socialLinks: [SocialLinkItem]
    private let aboutLinks: [AboutLinkItem]
    private let socialHeader: String
    private let aboutHeader: String
    private let reviewButtonTitle: String?
    private let reviewButtonSystemImage: String
    private let onRequestReview: (() -> Void)?
    private let version: String?
    private let build: String?

    public init(
        socialLinks: [SocialLinkItem],
        aboutLinks: [AboutLinkItem],
        socialHeader: String = "Social",
        aboutHeader: String = "About",
        reviewButtonTitle: String? = nil,
        reviewButtonSystemImage: String = "star.fill",
        onRequestReview: (() -> Void)? = nil,
        version: String? = nil,
        build: String? = nil
    ) {
        self.socialLinks = socialLinks
        self.aboutLinks = aboutLinks
        self.socialHeader = socialHeader
        self.aboutHeader = aboutHeader
        self.reviewButtonTitle = reviewButtonTitle
        self.reviewButtonSystemImage = reviewButtonSystemImage
        self.onRequestReview = onRequestReview
        self.version = version
        self.build = build
    }

    public var body: some View {
        socialSection
        aboutSection
    }

    @ViewBuilder
    private var socialSection: some View {
        Section(header: Text(socialHeader)) {
            ForEach(socialLinks) { item in
                HStack {
                    Image(item.imageName)
                        .symbolRenderingMode(.multicolor)
                        .accessibilityHidden(true)

                    if let url = item.url {
                        Link(item.title, destination: url)
                    } else {
                        Text(item.title)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        Section(aboutHeader) {
            ForEach(aboutLinks) { item in
                if let url = item.url {
                    Link(destination: url) {
                        Label(item.title, systemImage: item.systemImageName)
                            .foregroundStyle(item.tint)
                    }
                }
            }

            if let reviewButtonTitle, let onRequestReview {
                Button(reviewButtonTitle, systemImage: reviewButtonSystemImage) {
                    onRequestReview()
                }
                .foregroundStyle(.blue)
            }

            if let version {
                LabeledContent("Version", value: version)
            }

            if let build {
                LabeledContent("Build", value: build)
            }
        }
    }
}

