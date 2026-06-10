import UIKit

public extension UIImage {
    /// Returns a copy redrawn with `.up` orientation, so the pixel data matches
    /// the displayed orientation. Returns self when no redraw is needed or the
    /// image has a degenerate size.
    func fixOrientation() -> UIImage {
        guard imageOrientation != .up, size.width > 0, size.height > 0 else {
            return self
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
