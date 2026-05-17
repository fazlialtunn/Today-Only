//
//  TodayTaskFilter.swift
//  Today-Only
//

import Foundation

/// Centralized rules for which tasks are active today vs expired.
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

    /// Expired when created on a previous day, or created today with a past `expiresAt`.
    func isExpired(_ task: TodoTask, at referenceDate: Date? = nil) -> Bool {
        let reference = referenceDate ?? dateProvider.now()

        guard isCreatedToday(task.createdAt, relativeTo: reference) else {
            return true
        }

        guard let expiresAt = task.expiresAt else {
            return false
        }

        return expiresAt <= reference
    }

    /// Active tasks for the main today list.
    func isVisible(_ task: TodoTask, at referenceDate: Date? = nil) -> Bool {
        !isExpired(task, at: referenceDate)
    }

    func visibleTasks(from tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { isVisible($0) }
    }

    func expiredTasks(from tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { isExpired($0) }
    }

    func partition(_ tasks: [TodoTask]) -> (visible: [TodoTask], expired: [TodoTask]) {
        var visible: [TodoTask] = []
        var expired: [TodoTask] = []
        visible.reserveCapacity(tasks.count)
        expired.reserveCapacity(tasks.count)

        for task in tasks {
            if isVisible(task) {
                visible.append(task)
            } else {
                expired.append(task)
            }
        }
        return (visible, expired)
    }

    /// Tasks created on the current calendar day (ignores expiration).
    func tasksForToday(from tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { isCreatedToday($0) }
    }
}
