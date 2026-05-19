//
//  TaskComposerView.swift
//  Today-Only
//

import SwiftUI

struct TaskComposerView: View {
    @Binding var newTaskTitle: String
    @ObservedObject var viewModel: TodayTodoViewModel
    let onSubmit: () -> Void

    private var canSubmit: Bool {
        !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    TextField("New Reminder", text: $newTaskTitle)
                        .font(.body)
                        .submitLabel(.done)
                        .onSubmit(onSubmit)

                    Button(action: onSubmit) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(canSubmit ? Color.accentColor : Color(.tertiaryLabel))
                    .disabled(!canSubmit)
                    .accessibilityLabel("Add task")
                }

                Toggle("Expire at time", isOn: $viewModel.isExpirationEnabled)
                    .font(.subheadline)
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
                    .font(.subheadline)
                    .datePickerStyle(.compact)
                }

                if let message = viewModel.validationErrorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.validationError)
                }
            }
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.vertical, 12)
            .background(AppTheme.elevatedSurface)
        }
    }
}
