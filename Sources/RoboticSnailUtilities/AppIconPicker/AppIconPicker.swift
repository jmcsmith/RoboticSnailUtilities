//
//  AppIconPicker.swift
//  icons
//
//  Created by Joseph Beaudoin on 9/29/25.
//


import SwiftUI

public struct AppIconPicker: View {
    @Binding var selectedIconName: String?
    let options: [AppIconOption]
    let sectionName: String

    public var body: some View {
        Section(header: Text(sectionName)) {
            ForEach(options) { option in
                AppIconRow(option: option, selectedIconName: $selectedIconName)
            }
        }
        .animation(.default, value: selectedIconName)
    }
}
