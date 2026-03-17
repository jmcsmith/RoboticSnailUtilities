//
//  AppIconRow.swift
//  icons
//
//  Created by Joseph Beaudoin on 9/29/25.
//


import SwiftUI
import UIKit

public struct AppIconRow: View {
    let option: AppIconOption
    @Binding var selectedIconName: String?
    @State private var isChangingIcon = false
    
    public init(option: AppIconOption, selectedIconName: Binding<String?>) {
        self.option = option
        self._selectedIconName = selectedIconName
    }
    
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
        .onTapGesture {
            setIcon()
        }
    }
    
    @MainActor private func setIcon() {
        // Primary icon is set with `nil`
        let target = option.alternateIconName

        guard !isChangingIcon else { return }
        guard target != UIApplication.shared.alternateIconName else { return }

        isChangingIcon = true
        UIApplication.shared.setAlternateIconName(target) { error in
            Task { @MainActor in
                defer { isChangingIcon = false }

                if let error {
                    let nsError = error as NSError
                    print("Failed to set app icon")
                    print("targetIcon: \(target ?? "primary")")
                    print("description: \(error.localizedDescription)")
                    print("debugDescription: \(String(describing: error))")
                    print("domain: \(nsError.domain)")
                    print("code: \(nsError.code)")
                    print("failureReason: \(nsError.localizedFailureReason ?? "nil")")
                    print("recoverySuggestion: \(nsError.localizedRecoverySuggestion ?? "nil")")
                    print("recoveryOptions: \(nsError.localizedRecoveryOptions?.joined(separator: ", ") ?? "nil")")
                    print("helpAnchor: \(nsError.helpAnchor ?? "nil")")
                    if nsError.userInfo.isEmpty {
                        print("userInfo: empty")
                    } else {
                        print("userInfo:")
                        for (key, value) in nsError.userInfo {
                            print("  \(key): \(String(describing: value))")
                        }
                    }
                    return
                }

                selectedIconName = target
            }
        }
    }
}

