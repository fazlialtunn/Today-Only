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
            if viewModel.visibleTasks.isEmpty && !viewModel.isShowingExpired {
                TodayEmptyStateView()
            } else {
                List {
                    Section {
                        if viewModel.visibleTasks.isEmpty {
                            Text("No active tasks for today")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.visibleTasks) { task in
                                TaskRowView(task: task) {
                                    onToggle(task.id)
                                }
                            }
                        }
                    }

                    if viewModel.isShowingExpired {
                        Section {
                            if viewModel.expiredTasks.isEmpty {
                                Text("No expired tasks")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(viewModel.expiredTasks) { task in
                                    ExpiredTaskRowView(task: task)
                                }
                            }
                        } header: {
                            Text("Expired")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
