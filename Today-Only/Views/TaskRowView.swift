//
//  TaskRowView.swift
//  Today-Only
//

import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? Color.green : Color.secondary)

                Text(task.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .opacity(task.isCompleted ? 0.5 : 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to toggle completion")
    }
}
