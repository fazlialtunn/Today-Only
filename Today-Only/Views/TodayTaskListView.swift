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
                TodayEmptyStateView(style: TodayEmptyStateView.resolveWhenEmpty(for: viewModel))
            } else {
                List {
                    if TodayEmptyStateView.allTasksCompleted(in: viewModel) {
                        Section {
                            TodayEmptyStateView(style: .allCompleted, isCompact: true)
                                .listRowBackground(Color.clear)
                        }
                    }

                    Section {
                        if viewModel.visibleTasks.isEmpty {
                            TodayEmptyStateView(
                                style: TodayEmptyStateView.resolveWhenEmpty(for: viewModel),
                                isCompact: true
                            )
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(viewModel.visibleTasks) { task in
                                TaskRowView(task: task) {
                                    onToggle(task.id)
                                }
                                .listRowBackground(AppTheme.listRowBackground)
                            }
                        }
                    }

                    if viewModel.isShowingExpired {
                        Section {
                            if viewModel.expiredTasks.isEmpty {
                                Text("No expired tasks")
                                    .foregroundStyle(Color(.secondaryLabel))
                            } else {
                                ForEach(viewModel.expiredTasks) { task in
                                    ExpiredTaskRowView(task: task)
                                        .listRowBackground(AppTheme.listRowBackground)
                                }
                            }
                        } header: {
                            Text("Expired")
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.screenBackground)
    }
}
