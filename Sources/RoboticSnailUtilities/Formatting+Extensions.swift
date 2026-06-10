import Foundation

public extension Date {
    /// The full, locale-aware weekday name for this date (e.g. "Tuesday").
    func dayOfWeek() -> String {
        formatted(.dateTime.weekday(.wide))
    }
}

public extension Float {
    /// The value without a fractional part when it is a whole number ("2"
    /// instead of "2.0"); otherwise the standard description.
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

public extension Double {
    /// Formats the value, interpreted as a number of seconds, as an
    /// hour/minute/second duration string.
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
}
