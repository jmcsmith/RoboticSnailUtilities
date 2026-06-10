import SwiftUI
import UIKit

public struct AppIconRow: View {
    @MainActor private static var iconChangeInFlight = false
    let option: AppIconOption
    @Binding var selectedIconName: String?

    @ScaledMetric(relativeTo: .body) private var previewSize = 40.0

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
                preview(option.lightPreview)
                if let darkPreview = option.darkPreview {
                    preview(darkPreview)
                }
                if let monoPreview = option.monoPreview {
                    preview(monoPreview)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .imageScale(.medium)
                        .font(.body.weight(.semibold))
                        .transition(.opacity)
                        .accessibilityHidden(true)
                }
            }

            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func preview(_ assetName: String) -> some View {
        Image(decorative: assetName)
            .resizable()
            .frame(width: previewSize, height: previewSize)
            .clipShape(.rect(cornerRadius: 8))
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
        Task {
            defer { Self.iconChangeInFlight = false }
            do {
                try await app.setAlternateIconName(target)
                selectedIconName = target
            } catch {
                selectedIconName = app.alternateIconName
            }
        }
    }
}
