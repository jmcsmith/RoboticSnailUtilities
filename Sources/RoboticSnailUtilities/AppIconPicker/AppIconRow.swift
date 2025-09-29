//
//  AppIconRow.swift
//  icons
//
//  Created by Joseph Beaudoin on 9/29/25.
//


import SwiftUI

public struct AppIconRow: View {
    let option: AppIconOption
    @Binding var selectedIconName: String?
    
    var isSelected: Bool {
        selectedIconName == option.alternateIconName
    }
    
    public var body: some View {
        
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
            Text(option.title)
            
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
        .onTapGesture {
            setIcon()
        }
    }
    
    private func setIcon() {
        // Primary icon is set with `nil`
        let target = option.alternateIconName
        UIApplication.shared.setAlternateIconName(target) { error in
            // Optional: handle/log error
            // print(error?.localizedDescription ?? "Icon set")
        }
        selectedIconName = target
    }
}
