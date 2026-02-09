//
//  AppIconOption.swift
//  icons
//
//  Created by Joseph Beaudoin on 9/29/25.
//


import SwiftUI

// MARK: - Model

public struct AppIconOption: Identifiable, Equatable {
    public let id = UUID()
    /// Display name in the row (e.g., "Green Icon")
    public let title: String
    /// Optional secondary text shown under the title
    public let subtitle: String?
    /// Asset name for the light preview image
    public let lightPreview: String
    /// Asset name for the dark preview image
    public let darkPreview: String?
    /// Asset name for the mono preview image
    public let monoPreview: String?
    /// Alternate icon name from your Info.plist (nil for the primary/original icon)
    public let alternateIconName: String?
    
    // MARK: - Init
    public init(
        title: String,
        subtitle: String? = nil,
        lightPreview: String,
        darkPreview: String? = nil,
        monoPreview: String? = nil,
        alternateIconName: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.lightPreview = lightPreview
        self.darkPreview = darkPreview
        self.monoPreview = monoPreview
        self.alternateIconName = alternateIconName
    }
}

