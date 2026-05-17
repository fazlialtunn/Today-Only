//
//  ContentView.swift
//  Today-Only
//
//  Created by Fazlı Altun on 15.05.2026.
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
        VStack(spacing: 0) {
            TodayHeaderView(date: viewModel.currentDate)

            TodayTaskListView(viewModel: viewModel) { id in
                try? viewModel.toggleCompletion(for: id)
            }

            addTaskBar
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            try? viewModel.reloadTasks()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            try? viewModel.refreshForCurrentDay()
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 12) {
            TextField("New task", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit(submitNewTask)

            Button("Add", action: submitNewTask)
                .buttonStyle(.borderedProminent)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(.bar)
    }

    private func submitNewTask() {
        try? viewModel.addTask(title: newTaskTitle)
        newTaskTitle = ""
    }
}

#Preview {
    ContentView(
        viewModel: TodayTodoViewModel(
            store: TodoTaskStore(),
            dateProvider: SystemDateProvider()
        )
    )
}
