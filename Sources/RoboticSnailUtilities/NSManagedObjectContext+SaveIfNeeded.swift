import CoreData

public extension NSManagedObjectContext {
    /// Saves only when the context has changes. Returns whether a save occurred.
    @discardableResult func saveIfNeeded() throws -> Bool {
        guard hasChanges else {
            return false
        }
        try save()
        return true
    }
}
