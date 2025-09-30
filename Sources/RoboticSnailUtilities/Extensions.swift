//
//  Extensions.swift
//  
//
//  Created by Joe Beaudoin on 8/2/22.
//

import Foundation
import SwiftUI
import CoreData

public extension TextField {
    @ViewBuilder
    func editingStyle(if flag: Bool) -> some View {
        if flag {
            self.textFieldStyle(RoundedBorderTextFieldStyle())
        } else {
            self.textFieldStyle(PlainTextFieldStyle())
        }
    }
}
public extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
public extension NSManagedObjectContext {
    @discardableResult func saveIfNeeded() throws -> Bool {
        guard hasChanges else {
            return false
        }
        try save()
        return true
    }
}
public extension Array {
    func halves() -> ([Element], [Element]) {
        let half = count / 2
        let left = Array(self[..<half])
        let right = Array(self[half...])
        return (left, right)
    }
}
public extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
public extension Binding where Value == String? {
    func withDefaultValue(_ fallback: String) -> Binding<String> {
        return Binding<String>(get: {
            return self.wrappedValue ?? fallback
        }) { value in
            self.wrappedValue = value
        }
    }
}
public extension Binding where Value == Date? {
    func withDefaultValue(_ fallback: Date) -> Binding<Date> {
        return Binding<Date>(get: {
            return self.wrappedValue ?? fallback
        }) { value in
            self.wrappedValue = value
        }
    }
}
public extension Binding {
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}
public extension Date {
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
}
public extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
public extension UIImage {
    func fixOrientation() -> UIImage {
        if (self.imageOrientation == .up) {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
public extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    //formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    return formatter.string(from: self) ?? ""
  }
}
public extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    func toHex() -> String? {
          let uic = UIColor(self)
          guard let components = uic.cgColor.components, components.count >= 3 else {
              return nil
          }
          let r = Float(components[0])
          let g = Float(components[1])
          let b = Float(components[2])
          var a = Float(1.0)

          if components.count >= 4 {
              a = Float(components[3])
          }

          if a != Float(1.0) {
              return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
          } else {
              return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
          }
      }
}
