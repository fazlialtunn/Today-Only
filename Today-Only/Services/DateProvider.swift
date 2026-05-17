//
//  DateProvider.swift
//  Today-Only
//

import Foundation

/// Supplies the current moment and calendar for day-boundary logic (testable).
protocol DateProviding {
    var calendar: Calendar { get }
    func now() -> Date
}

struct SystemDateProvider: DateProviding {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func now() -> Date {
        Date()
    }
}

/// Fixed clock for unit tests and previews.
struct FixedDateProvider: DateProviding {
    let calendar: Calendar
    let fixedDate: Date

    init(fixedDate: Date, calendar: Calendar = .current) {
        self.fixedDate = fixedDate
        self.calendar = calendar
    }

    func now() -> Date {
        fixedDate
    }
}
