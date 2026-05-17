//
//  TodayTaskFilter.swift
//  Today-Only
//

import Foundation

/// Filters tasks to those created on the current calendar day.
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

    func tasksForToday(from tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { isCreatedToday($0) }
    }
}
