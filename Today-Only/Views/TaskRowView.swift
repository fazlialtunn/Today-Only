//
//  TaskRowView.swift
//  Today-Only
//

import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggle: () -> Void

    private static let completionAnimation = Animation.easeInOut(duration: 0.25)

    var body: some View {
        Button {
            withAnimation(Self.completionAnimation) {
                onToggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? AppTheme.completedCheckmark : Color(.tertiaryLabel))
                    .scaleEffect(task.isCompleted ? 1 : 0.92)

                Text(task.title)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? Color(.secondaryLabel) : Color(.label))
                    .strikethrough(task.isCompleted, color: Color(.secondaryLabel))
                    .opacity(task.isCompleted ? 0.65 : 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .animation(Self.completionAnimation, value: task.isCompleted)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to toggle completion")
    }
}
