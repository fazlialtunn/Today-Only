//
//  TaskRowView.swift
//  Today-Only
//

import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggle: () -> Void

    private static let completionAnimation = Animation.easeInOut(duration: 0.22)

    var body: some View {
        Button {
            withAnimation(Self.completionAnimation) {
                onToggle()
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(task.isCompleted ? Color.accentColor : Color(.tertiaryLabel))

                Text(task.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .strikethrough(task.isCompleted, pattern: .solid, color: Color(.tertiaryLabel))
                    .opacity(task.isCompleted ? 0.45 : 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, AppTheme.rowVerticalPadding)
            .animation(Self.completionAnimation, value: task.isCompleted)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to toggle completion")
    }
}
