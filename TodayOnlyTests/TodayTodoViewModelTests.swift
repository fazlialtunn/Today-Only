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

        XCTAssertEqual(viewModel.visibleTasks.count, 1)
        XCTAssertEqual(viewModel.visibleTasks.first?.title, "Buy milk")
        XCTAssertFalse(viewModel.visibleTasks.first?.isCompleted ?? true)
    }

    func test_yesterdayTasksAreHiddenFromVisibleList() throws {
        try seedTask(title: "Yesterday task", createdOn: yesterday)

        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.reloadTasks()

        XCTAssertTrue(viewModel.visibleTasks.isEmpty)
    }

    func test_yesterdayTasksAppearInExpiredList() throws {
        try seedTask(title: "Yesterday task", createdOn: yesterday)

        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.reloadTasks()

        XCTAssertEqual(viewModel.expiredTasks.count, 1)
        XCTAssertEqual(viewModel.expiredTasks.first?.title, "Yesterday task")
    }

    func test_addTaskAddsNewTask() throws {
        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.reloadTasks()
        XCTAssertTrue(viewModel.visibleTasks.isEmpty)

        try viewModel.addTask(title: "Walk the dog")

        XCTAssertEqual(viewModel.visibleTasks.count, 1)
        XCTAssertEqual(viewModel.visibleTasks.first?.title, "Walk the dog")
    }

    func test_toggleCompletionUpdatesTask() throws {
        let viewModel = makeViewModel(fixedDate: today)
        try viewModel.addTask(title: "Read a chapter")
        let taskID = try XCTUnwrap(viewModel.visibleTasks.first?.id)

        try viewModel.toggleCompletion(for: taskID)

        XCTAssertTrue(viewModel.visibleTasks.first?.isCompleted ?? false)

        try viewModel.toggleCompletion(for: taskID)

        XCTAssertFalse(viewModel.visibleTasks.first?.isCompleted ?? true)
    }

    func test_expiredTaskIsHiddenFromVisibleList() throws {
        let createdAt = today!
        let expiredAt = testCalendar.date(byAdding: .hour, value: 1, to: createdAt)!
        try seedTask(
            title: "Expired task",
            createdOn: createdAt,
            expiresAt: expiredAt
        )

        let afterExpiration = testCalendar.date(byAdding: .hour, value: 2, to: createdAt)!
        let viewModel = makeViewModel(fixedDate: afterExpiration)
        try viewModel.reloadTasks()

        XCTAssertTrue(viewModel.visibleTasks.isEmpty)
    }

    func test_expiredTaskAppearsInExpiredList() throws {
        let createdAt = today!
        let expiredAt = testCalendar.date(byAdding: .hour, value: 1, to: createdAt)!
        try seedTask(
            title: "Expired task",
            createdOn: createdAt,
            expiresAt: expiredAt
        )

        let afterExpiration = testCalendar.date(byAdding: .hour, value: 2, to: createdAt)!
        let viewModel = makeViewModel(fixedDate: afterExpiration)
        try viewModel.reloadTasks()

        XCTAssertEqual(viewModel.expiredTasks.count, 1)
        XCTAssertEqual(viewModel.expiredTasks.first?.title, "Expired task")
    }

    func test_futureExpirationTaskIsVisible() throws {
        let createdAt = today!
        let expiresAt = testCalendar.date(byAdding: .hour, value: 2, to: createdAt)!
        try seedTask(
            title: "Later task",
            createdOn: createdAt,
            expiresAt: expiresAt
        )

        let viewModel = makeViewModel(fixedDate: createdAt)
        try viewModel.reloadTasks()

        XCTAssertEqual(viewModel.visibleTasks.count, 1)
        XCTAssertEqual(viewModel.visibleTasks.first?.title, "Later task")
        XCTAssertTrue(viewModel.expiredTasks.isEmpty)
    }

    func test_addTaskRejectsPastExpiration() throws {
        let viewModel = makeViewModel(fixedDate: today)
        viewModel.isExpirationEnabled = true
        viewModel.selectedExpirationTime = today

        XCTAssertThrowsError(try viewModel.addTask(title: "Invalid")) { error in
            guard case TodayTodoViewModelError.invalidExpiration = error else {
                return XCTFail("Expected invalidExpiration, got \(error)")
            }
        }
        XCTAssertTrue(viewModel.visibleTasks.isEmpty)
    }

    // MARK: - Helpers

    private func makeViewModel(fixedDate: Date) -> TodayTodoViewModel {
        let dateProvider = FixedDateProvider(fixedDate: fixedDate, calendar: testCalendar)
        let store = TodoTaskStore(fileURL: tempFileURL, dateProvider: dateProvider)
        let viewModel = TodayTodoViewModel(
            store: store,
            dateProvider: dateProvider,
            notificationScheduler: NoOpTaskNotificationScheduler()
        )
        viewModel.clampSelectedExpirationTime()
        return viewModel
    }

    private func seedTask(
        title: String,
        createdOn date: Date,
        expiresAt: Date? = nil
    ) throws {
        let dateProvider = FixedDateProvider(fixedDate: date, calendar: testCalendar)
        let store = TodoTaskStore(fileURL: tempFileURL, dateProvider: dateProvider)
        _ = try store.addTask(title: title, expiresAt: expiresAt)
    }

    private static func makeTestCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
}
