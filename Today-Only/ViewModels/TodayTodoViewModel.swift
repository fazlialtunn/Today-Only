//
//  TodayTodoViewModel.swift
//  Today-Only
//

import Combine
import Foundation

enum TodayTodoViewModelError: LocalizedError, Equatable {
    case invalidExpiration(TaskExpirationValidationError)

    var errorDescription: String? {
        switch self {
        case .invalidExpiration(let error):
            return error.errorDescription
        }
    }
}

@MainActor
final class TodayTodoViewModel: ObservableObject {
    @Published private(set) var visibleTasks: [TodoTask] = []
    @Published private(set) var expiredTasks: [TodoTask] = []
    @Published var isShowingExpired = false
    @Published var isExpirationEnabled = false
    @Published var selectedExpirationTime: Date
    @Published private(set) var validationErrorMessage: String?

    private let store: TodoTaskStoring
    private let dateProvider: DateProviding
    private let todayFilter: TodayTaskFilter
    private let expirationValidator: TaskExpirationValidator
    private let notificationScheduler: TaskNotificationScheduling
    private var lastKnownDayKey: String?

    /// Current moment from the injected clock (used for the header date).
    var currentDate: Date {
        dateProvider.now()
    }

    /// Allowed range for the expiration time picker: from now through end of today.
    var expirationTimeRange: ClosedRange<Date> {
        let now = dateProvider.now()
        let end = dateProvider.calendar.endOfDay(for: now)
        if now <= end {
            return now ... end
        }
        return now ... now
    }

    init(
        store: TodoTaskStoring,
        dateProvider: DateProviding,
        todayFilter: TodayTaskFilter? = nil,
        notificationScheduler: TaskNotificationScheduling? = nil
    ) {
        self.store = store
        self.dateProvider = dateProvider
        self.todayFilter = todayFilter ?? TodayTaskFilter(dateProvider: dateProvider)
        self.expirationValidator = TaskExpirationValidator(dateProvider: dateProvider)
        self.notificationScheduler = notificationScheduler
            ?? NotificationScheduler(dateProvider: dateProvider)
        self.selectedExpirationTime = dateProvider.now()
    }

    func requestNotificationAuthorizationIfNeeded() async {
        _ = await notificationScheduler.requestAuthorizationIfNeeded()
    }

    /// Loads from storage and publishes visible and expired task lists.
    func reloadTasks() throws {
        let allTasks = try store.loadAllTasks()
        let partitioned = todayFilter.partition(allTasks)
        visibleTasks = Self.sortByCreatedAtAscending(partitioned.visible)
        expiredTasks = Self.sortByCreatedAtDescending(partitioned.expired)
        lastKnownDayKey = currentDayKey()
        clampSelectedExpirationTime()
    }

    /// Reloads when the calendar day changes.
    func refreshForCurrentDay() throws {
        let dayKey = currentDayKey()
        guard dayKey != lastKnownDayKey else { return }
        try reloadTasks()
    }

    /// Re-applies expiration filtering (e.g. when `now` passes `expiresAt`).
    func refreshExpiredTasks() throws {
        try reloadTasks()
    }

    /// Adds a task when `title` contains non-whitespace text; otherwise no-op.
    func addTask(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let expiresAt = try resolvedExpirationDateForNewTask()
        let task: TodoTask
        do {
            task = try store.addTask(title: trimmed, expiresAt: expiresAt)
        } catch let error as TodoTaskStoreError {
            if case .invalidExpiration(let validationError) = error {
                throw TodayTodoViewModelError.invalidExpiration(validationError)
            }
            throw error
        }
        validationErrorMessage = nil
        try reloadTasks()
        scheduleNotification(for: task)
    }

    func toggleCompletion(for id: UUID) throws {
        guard let index = visibleTasks.firstIndex(where: { $0.id == id }) else { return }

        var updated = visibleTasks[index]
        updated.isCompleted.toggle()
        try store.updateTask(updated)
        visibleTasks[index] = updated
        if updated.isCompleted {
            cancelNotification(for: id)
        } else {
            scheduleNotification(for: updated)
        }
    }

    func clampSelectedExpirationTime() {
        let range = expirationTimeRange
        if selectedExpirationTime < range.lowerBound {
            selectedExpirationTime = range.lowerBound
        } else if selectedExpirationTime > range.upperBound {
            selectedExpirationTime = range.upperBound
        }
    }

    // MARK: - Private

    private func resolvedExpirationDateForNewTask() throws -> Date? {
        guard isExpirationEnabled else { return nil }

        let createdAt = dateProvider.now()
        do {
            try expirationValidator.validate(expiresAt: selectedExpirationTime, createdAt: createdAt)
        } catch let error as TaskExpirationValidationError {
            validationErrorMessage = error.errorDescription
            throw TodayTodoViewModelError.invalidExpiration(error)
        }
        return selectedExpirationTime
    }

    private func currentDayKey() -> String {
        Self.dayKey(for: dateProvider.now(), calendar: dateProvider.calendar)
    }

    private func scheduleNotification(for task: TodoTask) {
        Task {
            await notificationScheduler.scheduleReminder(for: task)
        }
    }

    private func cancelNotification(for taskID: UUID) {
        Task {
            await notificationScheduler.cancelReminder(for: taskID)
        }
    }

    private static func sortByCreatedAtAscending(_ tasks: [TodoTask]) -> [TodoTask] {
        tasks.sorted { $0.createdAt < $1.createdAt }
    }

    private static func sortByCreatedAtDescending(_ tasks: [TodoTask]) -> [TodoTask] {
        tasks.sorted { $0.createdAt > $1.createdAt }
    }

    private static func dayKey(for date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: calendar.startOfDay(for: date))
    }
}
