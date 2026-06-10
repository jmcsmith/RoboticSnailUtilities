import Foundation

public extension Array {
    /// Splits the array at its midpoint. The right half receives the extra
    /// element when the count is odd.
    func halves() -> ([Element], [Element]) {
        let half = count / 2
        let left = Array(self[..<half])
        let right = Array(self[half...])
        return (left, right)
    }
}

public extension Sequence where Iterator.Element: Hashable {
    /// Returns the unique elements of the sequence, preserving first-seen order.
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
