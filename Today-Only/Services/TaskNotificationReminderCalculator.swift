//
//  TaskNotificationReminderCalculator.swift
//  Today-Only
//

import Foundation

/// Computes same-day reminder fire dates (10 minutes before expiration).
struct TaskNotificationReminderCalculator {
    private let dateProvider: DateProviding
    private let leadTime: TimeInterval

    init(dateProvider: DateProviding, leadTime: TimeInterval = 10 * 60) {
        self.dateProvider = dateProvider
        self.leadTime = leadTime
    }

    /// Returns a future reminder time on the task's creation day, or `nil` if none should be scheduled.
    func reminderDate(for task: TodoTask) -> Date? {
        let calendar = dateProvider.calendar
        let now = dateProvider.now()

        guard calendar.isDate(task.createdAt, inSameDayAs: now) else {
            return nil
        }

        let expirationDate = expirationDate(for: task, calendar: calendar)
        guard calendar.isDate(expirationDate, inSameDayAs: task.createdAt) else {
            return nil
        }

        let fireDate = expirationDate.addingTimeInterval(-leadTime)
        guard fireDate > now else { return nil }
        guard calendar.isDate(fireDate, inSameDayAs: task.createdAt) else { return nil }

        return fireDate
    }

    private func expirationDate(for task: TodoTask, calendar: Calendar) -> Date {
        if let expiresAt = task.expiresAt {
            return expiresAt
        }
        return calendar.endOfDay(for: task.createdAt)
    }
}
