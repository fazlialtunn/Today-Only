//
//  TaskNotificationReminderCalculatorTests.swift
//  TodayOnlyTests
//

import XCTest
@testable import Today_Only

final class TaskNotificationReminderCalculatorTests: XCTestCase {
    private var calendar: Calendar!
    private var today: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        today = calendar.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 12))!
    }

    func test_reminderDate_isTenMinutesBeforeExpiresAt() {
        let expiresAt = calendar.date(byAdding: .hour, value: 2, to: today)!
        let task = TodoTask(title: "Test", createdAt: today, expiresAt: expiresAt)
        let calculator = makeCalculator(now: today)

        let reminder = calculator.reminderDate(for: task)

        let expected = expiresAt.addingTimeInterval(-10 * 60)
        XCTAssertEqual(reminder, expected)
    }

    func test_reminderDate_isTenMinutesBeforeEndOfDayWhenNoExpiresAt() {
        let task = TodoTask(title: "Test", createdAt: today)
        let calculator = makeCalculator(now: today)

        let reminder = calculator.reminderDate(for: task)
        let endOfDay = calendar.endOfDay(for: today)
        let expected = endOfDay.addingTimeInterval(-10 * 60)

        XCTAssertEqual(reminder, expected)
    }

    func test_reminderDate_returnsNilWhenInPast() {
        let expiresAt = calendar.date(byAdding: .minute, value: 5, to: today)!
        let task = TodoTask(title: "Test", createdAt: today, expiresAt: expiresAt)
        let afterExpirationWindow = calendar.date(byAdding: .minute, value: 2, to: today)!
        let calculator = makeCalculator(now: afterExpirationWindow)

        XCTAssertNil(calculator.reminderDate(for: task))
    }

    func test_reminderDate_returnsNilForPreviousDayTask() {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let task = TodoTask(title: "Old", createdAt: yesterday)
        let calculator = makeCalculator(now: today)

        XCTAssertNil(calculator.reminderDate(for: task))
    }

    private func makeCalculator(now: Date) -> TaskNotificationReminderCalculator {
        TaskNotificationReminderCalculator(
            dateProvider: FixedDateProvider(fixedDate: now, calendar: calendar)
        )
    }
}
