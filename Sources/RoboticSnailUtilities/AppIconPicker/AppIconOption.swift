//
//  AppIconOption.swift
//  icons
//
//  Created by Joseph Beaudoin on 9/29/25.
//


import SwiftUI

// MARK: - Model

struct AppIconOption: Identifiable, Equatable {
    let id = UUID()
    /// Display name in the row (e.g., "Green Icon")
    let title: String
    /// Asset name for the light preview image
    let lightPreview: String
    /// Asset name for the dark preview image
    let darkPreview: String?
    /// Alternate icon name from your Info.plist (nil for the primary/original icon)
    let alternateIconName: String?
}
