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
                "checklist",
                "Start fresh today",
                "What do you want to get done? Add a task below — it only counts for today."
            )
        case .allCompleted:
            return (
                "checkmark.circle",
                "You're all caught up",
                "Every task for today is done. Enjoy the rest of your day."
            )
        case .noActiveTasks:
            return (
                "clock",
                "Nothing active right now",
                "Today's tasks have wrapped up. Add something new below when you're ready."
            )
        }
    }

    var body: some View {
        let copy = content

        VStack(spacing: isCompact ? 10 : 16) {
            Image(systemName: copy.icon)
                .font(.system(size: isCompact ? 32 : 52, weight: .light))
                .foregroundStyle(Color(.secondaryLabel))
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            VStack(spacing: isCompact ? 6 : 8) {
                Text(copy.title)
                    .font(isCompact ? .subheadline.weight(.semibold) : .title3.weight(.semibold))
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.center)

                Text(copy.message)
                    .font(isCompact ? .footnote : .subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .frame(maxWidth: isCompact ? .infinity : 300)
        }
        .frame(maxWidth: .infinity, maxHeight: isCompact ? nil : .infinity)
        .padding(.horizontal, isCompact ? 16 : 32)
        .padding(.vertical, isCompact ? 12 : 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(copy.title). \(copy.message)")
    }
}

extension TodayEmptyStateView {
    /// Style when the main list has no visible tasks.
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

#Preview("All completed") {
    TodayEmptyStateView(style: .allCompleted)
        .background(AppTheme.screenBackground)
}

#Preview("Dark") {
    TodayEmptyStateView(style: .noTasksYet)
        .background(AppTheme.screenBackground)
        .preferredColorScheme(.dark)
}
