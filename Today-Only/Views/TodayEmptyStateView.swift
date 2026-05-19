//
//  TodayEmptyStateView.swift
//  Today-Only
//

import SwiftUI

enum TodayEmptyStateStyle: Equatable {
    case noTasksYet
    case allCompleted
    case noActiveTasks
}

struct TodayEmptyStateView: View {
    let style: TodayEmptyStateStyle
    var isCompact: Bool = false

    private var content: (icon: String, title: String, message: String) {
        switch style {
        case .noTasksYet:
            return (
                "tray",
                "No Reminders",
                "Add a task below."
            )
        case .allCompleted:
            return (
                "checkmark.circle",
                "All Done",
                "You have completed every task for today."
            )
        case .noActiveTasks:
            return (
                "clock",
                "No Active Tasks",
                "Earlier tasks have expired. Add a new one below."
            )
        }
    }

    var body: some View {
        let copy = content

        VStack(spacing: isCompact ? 8 : 12) {
            Image(systemName: copy.icon)
                .font(.system(size: isCompact ? 28 : 36, weight: .light))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(copy.title)
                    .font(isCompact ? .subheadline.weight(.medium) : .headline)
                    .foregroundStyle(.secondary)

                Text(copy.message)
                    .font(isCompact ? .caption : .subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: isCompact ? .infinity : 260)
        }
        .frame(maxWidth: .infinity, maxHeight: isCompact ? nil : .infinity)
        .padding(.horizontal, AppTheme.horizontalPadding)
        .padding(.vertical, isCompact ? 8 : 32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(copy.title). \(copy.message)")
    }
}

extension TodayEmptyStateView {
    static func resolveWhenEmpty(for viewModel: TodayTodoViewModel) -> TodayEmptyStateStyle {
        let hadTasksToday = viewModel.expiredTasks.contains {
            Calendar.current.isDateInToday($0.createdAt)
        }
        return hadTasksToday ? .noActiveTasks : .noTasksYet
    }

    static func allTasksCompleted(in viewModel: TodayTodoViewModel) -> Bool {
        let visible = viewModel.visibleTasks
        return !visible.isEmpty && visible.allSatisfy(\.isCompleted)
    }
}

#Preview("No tasks") {
    TodayEmptyStateView(style: .noTasksYet)
        .background(AppTheme.screenBackground)
}

#Preview("Dark") {
    TodayEmptyStateView(style: .noTasksYet)
        .background(AppTheme.screenBackground)
        .preferredColorScheme(.dark)
}
