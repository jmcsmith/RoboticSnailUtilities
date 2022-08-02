//
//  LogStore.swift
//  LoggerTest
//
//  Created by Joe Beaudoin on 8/2/22.
//

import OSLog
import Foundation

@MainActor public class LogStore: ObservableObject {
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "🟢"
    )
     static let errors = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "🔴"
    )
     static let info = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "🔵"
    )
     static let warning = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "🟡"
    )
    @Published private(set) var entries: [String] = []

    func export() {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let date = Date.now.addingTimeInterval(-24 * 3600)
            let position = store.position(date: date)
            
            entries = try store
                .getEntries(at: position)
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
                .map { "\($0.category) - [\($0.date.formatted())] \($0.composedMessage)" }
        } catch {
            Self.logger.warning("\(error.localizedDescription, privacy: .public)")
        }
    }
}
