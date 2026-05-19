//
//  ContentView.swift
//  Today-Only
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: TodayTodoViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var newTaskTitle = ""

    init(viewModel: TodayTodoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            TodayTaskListView(viewModel: viewModel, onToggle: toggleTask)
                .navigationTitle("Today")
                .navigationBarTitleDisplayMode(.large)
                .background(AppTheme.screenBackground)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    TaskComposerView(
                        newTaskTitle: $newTaskTitle,
                        viewModel: viewModel,
                        onSubmit: submitNewTask
                    )
                }
        }
        .background(AppTheme.screenBackground)
        .onAppear {
            HapticFeedback.prepareGenerators()
            viewModel.clampSelectedExpirationTime()
            try? viewModel.reloadTasks()
            viewModel.startExpirationMonitoring()
            Task {
                await viewModel.requestNotificationAuthorizationIfNeeded()
            }
        }
        .onDisappear {
            viewModel.stopExpirationMonitoring()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                viewModel.clampSelectedExpirationTime()
                try? viewModel.refreshForCurrentDay()
                try? viewModel.refreshExpiredTasks()
                viewModel.startExpirationMonitoring()
            case .background, .inactive:
                viewModel.stopExpirationMonitoring()
            @unknown default:
                break
            }
        }
    }

    private func submitNewTask() {
        do {
            try viewModel.addTask(title: newTaskTitle)
            newTaskTitle = ""
            HapticFeedback.taskAdded()
        } catch {
            // validationErrorMessage is set by the view model
        }
    }

    private func toggleTask(id: UUID) {
        guard viewModel.visibleTasks.contains(where: { $0.id == id }) else { return }
        try? viewModel.toggleCompletion(for: id)
        HapticFeedback.taskToggled()
    }
}

#Preview("Light") {
    ContentView(
        viewModel: TodayTodoViewModel(
            store: TodoTaskStore(),
            dateProvider: SystemDateProvider()
        )
    )
}

#Preview("Dark") {
    ContentView(
        viewModel: TodayTodoViewModel(
            store: TodoTaskStore(),
            dateProvider: SystemDateProvider()
        )
    )
    .preferredColorScheme(.dark)
}
