import SwiftUI

public struct AppIconPicker: View {
    @Binding var selectedIconName: String?
    let options: [AppIconOption]
    let sectionName: String

    public init(selectedIconName: Binding<String?>, options: [AppIconOption], sectionName: String) {
        self._selectedIconName = selectedIconName
        self.options = options
        self.sectionName = sectionName
    }

    public var body: some View {
        Section(sectionName) {
            ForEach(options) { option in
                AppIconRow(option: option, selectedIconName: $selectedIconName)
            }
        }
        .animation(.default, value: selectedIconName)
    }
}
