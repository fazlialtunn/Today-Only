//
//  TaskExpirationValidator.swift
//  Today-Only
//

import Foundation

enum TaskExpirationValidationError: LocalizedError, Equatable {
    case expiresAtInPast
    case expiresAtBeforeCreatedAt
    case expiresAtNotSameDayAsCreatedAt

    var errorDescription: String? {
        switch self {
        case .expiresAtInPast:
            return "Expiration time must be in the future."
        case .expiresAtBeforeCreatedAt:
            return "Expiration time cannot be before the task was created."
        case .expiresAtNotSameDayAsCreatedAt:
            return "Expiration time must be on the same day as the task."
        }
    }
}

struct TaskExpirationValidator {
    let calendar: Calendar
    private let now: () -> Date

    init(calendar: Calendar, now: @escaping () -> Date) {
        self.calendar = calendar
        self.now = now
    }

    init(dateProvider: DateProviding) {
        self.init(calendar: dateProvider.calendar, now: dateProvider.now)
    }

    func validate(expiresAt: Date?, createdAt: Date) throws {
        guard let expiresAt else { return }

        guard calendar.isDate(expiresAt, inSameDayAs: createdAt) else {
            throw TaskExpirationValidationError.expiresAtNotSameDayAsCreatedAt
        }

        guard expiresAt > createdAt else {
            throw TaskExpirationValidationError.expiresAtBeforeCreatedAt
        }

        guard expiresAt > now() else {
            throw TaskExpirationValidationError.expiresAtInPast
        }
    }
}
