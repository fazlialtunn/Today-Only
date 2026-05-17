//
//  TodoTaskStore.swift
//  Today-Only
//

import Foundation

enum TodoTaskStoreError: LocalizedError {
    case emptyTitle
    case taskNotFound(UUID)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Task title cannot be empty."
        case .taskNotFound(let id):
            return "No task found with id \(id.uuidString)."
        }
    }
}

protocol TodoTaskStoring {
    func loadTasks() throws -> [TodoTask]
    func saveTasks(_ tasks: [TodoTask]) throws
    @discardableResult
    func addTask(title: String) throws -> TodoTask
    func updateTask(_ task: TodoTask) throws
}

final class TodoTaskStore: TodoTaskStoring {
    private let fileURL: URL
    private let dateProvider: DateProviding
    private let todayFilter: TodayTaskFilter
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileURL: URL? = nil,
        dateProvider: DateProviding = SystemDateProvider(),
        fileManager: FileManager = .default
    ) {
        self.fileURL = fileURL ?? Self.defaultFileURL(fileManager: fileManager)
        self.dateProvider = dateProvider
        self.todayFilter = TodayTaskFilter(dateProvider: dateProvider)
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    /// Returns only tasks whose `createdAt` falls on the current calendar day.
    func loadTasks() throws -> [TodoTask] {
        let stored = try readPersistedTasksFromDisk()
        return todayFilter.tasksForToday(from: stored.tasks)
    }

    /// Replaces today's tasks while preserving tasks from previous days on disk.
    func saveTasks(_ tasks: [TodoTask]) throws {
        var stored = try readPersistedTasksFromDisk()
        let olderTasks = stored.tasks.filter { !todayFilter.isCreatedToday($0) }
        stored.tasks = olderTasks + tasks
        try persist(stored)
    }

    @discardableResult
    func addTask(title: String) throws -> TodoTask {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TodoTaskStoreError.emptyTitle }

        var stored = try readPersistedTasksFromDisk()
        let task = TodoTask(title: trimmed, createdAt: dateProvider.now())
        stored.tasks.append(task)
        try persist(stored)
        return task
    }

    func updateTask(_ task: TodoTask) throws {
        var stored = try readPersistedTasksFromDisk()
        guard let index = stored.tasks.firstIndex(where: { $0.id == task.id }) else {
            throw TodoTaskStoreError.taskNotFound(task.id)
        }
        stored.tasks[index] = task
        try persist(stored)
    }

    // MARK: - Private

    private func readPersistedTasksFromDisk() throws -> PersistedTasks {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return PersistedTasks()
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(PersistedTasks.self, from: data)
    }

    private func persist(_ persisted: PersistedTasks) throws {
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(persisted)
        try data.write(to: fileURL, options: .atomic)
    }

    private static func defaultFileURL(fileManager: FileManager) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base
            .appendingPathComponent("Today-Only", isDirectory: true)
            .appendingPathComponent("tasks.json", isDirectory: false)
    }
}
