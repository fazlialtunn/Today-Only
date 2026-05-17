//
//  PersistedTasks.swift
//  Today-Only
//

import Foundation

/// Full on-disk task history. Visibility for "today" is applied when loading.
struct PersistedTasks: Codable, Equatable {
    var tasks: [TodoTask]

    init(tasks: [TodoTask] = []) {
        self.tasks = tasks
    }

    private enum CodingKeys: String, CodingKey {
        case tasks
        case dayKey
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tasks = try container.decode([TodoTask].self, forKey: .tasks)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tasks, forKey: .tasks)
    }
}
