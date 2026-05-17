//
//  TodayTaskListView.swift
//  Today-Only
//

import SwiftUI

struct TodayTaskListView: View {
    @ObservedObject var viewModel: TodayTodoViewModel
    let onToggle: (UUID) -> Void

    var body: some View {
        Group {
            if viewModel.tasks.isEmpty {
                TodayEmptyStateView()
            } else {
                List {
                    ForEach(viewModel.tasks) { task in
                        TaskRowView(task: task) {
                            onToggle(task.id)
                        }
                        .listRowSeparator(.visible)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
