import SwiftUI

/// Strokes a rectangle over the content. Applied unconditionally; prefer
/// `View.debugBorder(color:)`, which compiles to nothing outside DEBUG builds.
public struct DebugBorder: ViewModifier {
    let color: Color

    public init(color: Color) { self.color = color }

    public func body(content: Content) -> some View {
        content.overlay(Rectangle().stroke(color))
    }
}

public extension View {
    /// Debug-only border overlay for layout inspection. No-op in release builds.
    @ViewBuilder func debugBorder(color: Color = .blue) -> some View {
        #if DEBUG
        modifier(DebugBorder(color: color))
        #else
        self
        #endif
    }
}
