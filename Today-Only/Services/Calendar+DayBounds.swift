//
//  Calendar+DayBounds.swift
//  Today-Only
//

import Foundation

extension Calendar {
    /// Last representable instant on the same calendar day as `date`.
    func endOfDay(for date: Date) -> Date {
        let startOfDay = startOfDay(for: date)
        guard
            let startOfNextDay = self.date(byAdding: .day, value: 1, to: startOfDay),
            let endOfDay = self.date(byAdding: .second, value: -1, to: startOfNextDay)
        else {
            return date
        }
        return endOfDay
    }
}
