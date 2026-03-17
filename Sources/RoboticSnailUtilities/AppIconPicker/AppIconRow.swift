//
//  AppIconRow.swift
//  icons
//
//  Created by Joseph Beaudoin on 9/29/25.
//


import SwiftUI
import UIKit



public struct AppIconRow: View {
    @MainActor private static var iconChangeInFlight = false
    let option: AppIconOption
    @Binding var selectedIconName: String?
    
    public init(option: AppIconOption, selectedIconName: Binding<String?>) {
        self.option = option
        self._selectedIconName = selectedIconName
    }
    
    var isSelected: Bool {
        selectedIconName == option.alternateIconName
    }
    
    public var body: some View {
        Button(action: setIcon) {
            HStack {
                Image(option.lightPreview)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                if let darkPreview = option.darkPreview {
                    Image(darkPreview)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }
                if let monoPreview = option.monoPreview {
                    Image(monoPreview)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .imageScale(.medium)
                        .font(.body.weight(.semibold))
                        .transition(.opacity)
                }
            }
            
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @MainActor private func setIcon() {
        let app = UIApplication.shared
        let target = option.alternateIconName
        
        guard app.supportsAlternateIcons else { return }
        guard app.applicationState == .active else { return }
        guard target != app.alternateIconName else {
            selectedIconName = target
            return
        }
        guard !Self.iconChangeInFlight else { return }
        
        Self.iconChangeInFlight = true
        app.setAlternateIconName(target) { error in
            Task { @MainActor in
                Self.iconChangeInFlight = false
                if error == nil {
                    selectedIconName = target
                } else {
                    selectedIconName = app.alternateIconName
                }
            }
        }
    }
    
}

