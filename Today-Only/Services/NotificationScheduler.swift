//
//  NotificationScheduler.swift
//  Today-Only
//

import Foundation
import UserNotifications

final class NotificationScheduler: TaskNotificationScheduling {
    private let center: UNUserNotificationCenter
    private let calculator: TaskNotificationReminderCalculator
    private let calendar: Calendar

    init(
        dateProvider: DateProviding,
        center: UNUserNotificationCenter = .current()
    ) {
        self.center = center
        self.calculator = TaskNotificationReminderCalculator(dateProvider: dateProvider)
        self.calendar = dateProvider.calendar
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return await requestAuthorization()
        @unknown default:
            return false
        }
    }

    func scheduleReminder(for task: TodoTask) async {
        guard !task.isCompleted else { return }
        guard await requestAuthorizationIfNeeded() else { return }
        guard let fireDate = calculator.reminderDate(for: task) else { return }

        await cancelReminder(for: task.id)

        let content = UNMutableNotificationContent()
        content.title = "Task expiring soon"
        content.body = notificationBody(for: task)
        content.sound = .default

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: task.id),
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelReminder(for taskID: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: taskID)])
    }

    // MARK: - Private

    private func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    private func notificationIdentifier(for taskID: UUID) -> String {
        "today-only.task.\(taskID.uuidString)"
    }

    private func notificationBody(for task: TodoTask) -> String {
        if task.expiresAt != nil {
            return "\"\(task.title)\" expires in 10 minutes."
        }
        return "\"\(task.title)\" ends today in 10 minutes."
    }
}
