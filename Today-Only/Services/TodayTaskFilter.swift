//
//  TodayTaskFilter.swift
//  Today-Only
//

import Foundation

/// Filters tasks to those created today and not yet expired.
struct TodayTaskFilter {
    private let dateProvider: DateProviding

    init(dateProvider: DateProviding = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }

    func isCreatedToday(_ createdAt: Date, relativeTo referenceDate: Date? = nil) -> Bool {
        let reference = referenceDate ?? dateProvider.now()
        return dateProvider.calendar.isDate(createdAt, inSameDayAs: reference)
    }

    func isCreatedToday(_ task: TodoTask) -> Bool {
        isCreatedToday(task.createdAt)
    }

    /// A task has passed its expiration when an explicit `expiresAt` is in the past.
    /// Tasks without `expiresAt` rely on the calendar-day check in `isVisible`.
    func isExpired(_ task: TodoTask, at referenceDate: Date? = nil) -> Bool {
        guard let expiresAt = task.expiresAt else { return false }
        let reference = referenceDate ?? dateProvider.now()
        return expiresAt <= reference
    }

    /// Visible when created on the current day and not past an explicit expiration time.
    func isVisible(_ task: TodoTask, at referenceDate: Date? = nil) -> Bool {
        let reference = referenceDate ?? dateProvider.now()
        guard isCreatedToday(task.createdAt, relativeTo: reference) else { return false }
        return !isExpired(task, at: reference)
    }

    func visibleTasks(from tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { isVisible($0) }
    }

    /// Tasks created on the current calendar day (ignores time-based expiration).
    func tasksForToday(from tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { isCreatedToday($0) }
    }
}
