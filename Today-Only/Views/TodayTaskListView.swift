//
//  TodayTaskListView.swift
//  Today-Only
//

import SwiftUI

struct TodayTaskListView: View {
    @ObservedObject var viewModel: TodayTodoViewModel
    let onToggle: (UUID) -> Void

    var body: some View {
        List {
            Section {
                Text(viewModel.currentDate, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            if TodayEmptyStateView.allTasksCompleted(in: viewModel) {
                Section {
                    TodayEmptyStateView(style: .allCompleted, isCompact: true)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }

            Section {
                if viewModel.visibleTasks.isEmpty {
                    TodayEmptyStateView(
                        style: TodayEmptyStateView.resolveWhenEmpty(for: viewModel),
                        isCompact: true
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.visibleTasks) { task in
                        TaskRowView(task: task) {
                            onToggle(task.id)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
            }

            Section {
                Toggle("Show Expired", isOn: $viewModel.isShowingExpired)
                    .font(.body)
            }

            if viewModel.isShowingExpired {
                Section {
                    if viewModel.expiredTasks.isEmpty {
                        Text("No expired tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.expiredTasks) { task in
                            ExpiredTaskRowView(task: task)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        }
                    }
                } header: {
                    Text("Expired")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.screenBackground)
    }
}
