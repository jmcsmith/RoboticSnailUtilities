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
    let title: String
    /// Asset name for the light preview image
    let lightPreview: String
    /// Asset name for the dark preview image
    let darkPreview: String?
    /// Asset name for the mono preview image
    let monoPreview: String?
    /// Alternate icon name from your Info.plist (nil for the primary/original icon)
    let alternateIconName: String?
    
    // MARK: - Init
    public init(
        title: String,
        lightPreview: String,
        darkPreview: String? = nil,
        monoPreview: String? = nil,
        alternateIconName: String? = nil
    ) {
        self.title = title
        self.lightPreview = lightPreview
        self.darkPreview = darkPreview
        self.monoPreview = monoPreview
        self.alternateIconName = alternateIconName
    }
}
