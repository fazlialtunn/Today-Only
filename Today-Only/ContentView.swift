//
//  ContentView.swift
//  Today-Only
//

import Combine
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

            addTaskSection
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.clampSelectedExpirationTime()
            try? viewModel.reloadTasks()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            viewModel.clampSelectedExpirationTime()
            try? viewModel.refreshForCurrentDay()
            try? viewModel.refreshExpiredTasks()
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            try? viewModel.refreshExpiredTasks()
        }
    }

    private var addTaskSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                TextField("New task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit(submitNewTask)

                Button("Add", action: submitNewTask)
                    .buttonStyle(.borderedProminent)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Toggle("Expire at time", isOn: $viewModel.isExpirationEnabled)
                .onChange(of: viewModel.isExpirationEnabled) { _ in
                    viewModel.clampSelectedExpirationTime()
                }

            if viewModel.isExpirationEnabled {
                DatePicker(
                    "Expires",
                    selection: $viewModel.selectedExpirationTime,
                    in: viewModel.expirationTimeRange,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
            }

            if let message = viewModel.validationErrorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.bar)
    }

    private func submitNewTask() {
        do {
            try viewModel.addTask(title: newTaskTitle)
            newTaskTitle = ""
        } catch {
            // validationErrorMessage is set by the view model
        }
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
