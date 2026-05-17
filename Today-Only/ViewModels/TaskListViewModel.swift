//
//  TaskListViewModel.swift
//  Today-Only
//

import Combine
import Foundation

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []

    private let store: TodoTaskStoring
    private let dateProvider: DateProviding
    private let todayFilter: TodayTaskFilter
    private var lastKnownDayKey: String?

    init(
        store: TodoTaskStoring,
        dateProvider: DateProviding,
        todayFilter: TodayTaskFilter? = nil
    ) {
        self.store = store
        self.dateProvider = dateProvider
        self.todayFilter = todayFilter ?? TodayTaskFilter(dateProvider: dateProvider)
    }

    /// Loads from storage and publishes only tasks created on the current calendar day.
    func reloadTasks() throws {
        let loaded = try store.loadTasks()
        tasks = Self.sortedTodayTasks(from: loaded, using: todayFilter)
        lastKnownDayKey = currentDayKey()
    }

    /// Reloads when the calendar day changes (e.g. app returns from background after midnight).
    func refreshForCurrentDay() throws {
        let dayKey = currentDayKey()
        guard dayKey != lastKnownDayKey else { return }
        try reloadTasks()
    }

    /// Adds a task when `title` contains non-whitespace text; otherwise no-op.
    func addTask(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        _ = try store.addTask(title: trimmed)
        try reloadTasks()
    }

    func toggleCompletion(for id: UUID) throws {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }

        var updated = tasks[index]
        updated.isCompleted.toggle()
        try store.updateTask(updated)
        tasks[index] = updated
    }

    // MARK: - Private

    private func currentDayKey() -> String {
        Self.dayKey(for: dateProvider.now(), calendar: dateProvider.calendar)
    }

    private static func sortedTodayTasks(
        from tasks: [TodoTask],
        using filter: TodayTaskFilter
    ) -> [TodoTask] {
        filter.tasksForToday(from: tasks)
            .sorted { $0.createdAt < $1.createdAt }
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
