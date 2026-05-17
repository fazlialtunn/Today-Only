//
//  TodayTodoViewModelTests.swift
//  TodayOnlyTests
//

import XCTest
@testable import Today_Only

@MainActor
final class TodayTodoViewModelTests: XCTestCase {
    private var testCalendar: Calendar!
    private var today: Date!
    private var yesterday: Date!
    private var tempFileURL: URL!

    override func setUp() {
        super.setUp()
        testCalendar = Self.makeTestCalendar()
        today = testCalendar.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 12))!
        yesterday = testCalendar.date(byAdding: .day, value: -1, to: today)!

        tempFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("TodayOnlyTests-\(UUID().uuidString).json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempFileURL)
        super.tearDown()
    }

    func test_todayTasksAreVisible() throws {
        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.addTask(title: "Buy milk")
        try viewModel.reloadTasks()

        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks.first?.title, "Buy milk")
        XCTAssertFalse(viewModel.tasks.first?.isCompleted ?? true)
    }

    func test_yesterdayTasksAreHidden() throws {
        try seedTask(title: "Yesterday task", createdOn: yesterday)

        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.reloadTasks()

        XCTAssertTrue(viewModel.tasks.isEmpty)
    }

    func test_addTaskAddsNewTask() throws {
        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.reloadTasks()
        XCTAssertTrue(viewModel.tasks.isEmpty)

        try viewModel.addTask(title: "Walk the dog")

        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks.first?.title, "Walk the dog")
    }

    func test_toggleCompletionUpdatesTask() throws {
        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.addTask(title: "Read a chapter")
        let taskID = try XCTUnwrap(viewModel.tasks.first?.id)

        try viewModel.toggleCompletion(for: taskID)

        XCTAssertTrue(viewModel.tasks.first?.isCompleted ?? false)

        try viewModel.toggleCompletion(for: taskID)

        XCTAssertFalse(viewModel.tasks.first?.isCompleted ?? true)
    }

    // MARK: - Helpers

    private func makeViewModel(fixedDate: Date) -> TodayTodoViewModel {
        let dateProvider = FixedDateProvider(fixedDate: fixedDate, calendar: testCalendar)
        let store = TodoTaskStore(fileURL: tempFileURL, dateProvider: dateProvider)
        return TodayTodoViewModel(store: store, dateProvider: dateProvider)
    }

    private func seedTask(title: String, createdOn date: Date) throws {
        let dateProvider = FixedDateProvider(fixedDate: date, calendar: testCalendar)
        let store = TodoTaskStore(fileURL: tempFileURL, dateProvider: dateProvider)
        _ = try store.addTask(title: title)
    }

    private static func makeTestCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
}
