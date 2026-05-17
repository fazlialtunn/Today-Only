//
//  TodoTask.swift
//  Today-Only
//

import Foundation

struct TodoTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    /// Optional same-day expiration. When `nil`, the task is valid until end of the creation day.
    var expiresAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}
