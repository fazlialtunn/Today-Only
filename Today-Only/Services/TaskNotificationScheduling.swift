//
//  TaskNotificationScheduling.swift
//  Today-Only
//

import Foundation

protocol TaskNotificationScheduling {
    func requestAuthorizationIfNeeded() async -> Bool
    func scheduleReminder(for task: TodoTask) async
    func cancelReminder(for taskID: UUID) async
}

/// Test/no-op implementation.
struct NoOpTaskNotificationScheduler: TaskNotificationScheduling {
    func requestAuthorizationIfNeeded() async -> Bool { true }
    func scheduleReminder(for task: TodoTask) async {}
    func cancelReminder(for taskID: UUID) async {}
}
