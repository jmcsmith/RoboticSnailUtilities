import SwiftUI

public extension TextField {
    /// Shows a rounded border around the field while `flag` is true.
    ///
    /// Both states share one structural identity, so toggling the flag mid-edit
    /// keeps the field focused instead of dismissing the keyboard.
    func editingStyle(if flag: Bool) -> some View {
        self
            .textFieldStyle(.plain)
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.quaternary, lineWidth: 1)
                    .opacity(flag ? 1 : 0)
            )
    }
}
