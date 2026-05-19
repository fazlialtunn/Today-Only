//
//  ExpiredTaskRowView.swift
//  Today-Only
//

import SwiftUI

struct ExpiredTaskRowView: View {
    let task: TodoTask

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "clock")
                .font(.body)
                .foregroundStyle(.tertiary)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .strikethrough(true, color: Color(.tertiaryLabel))

                Text(task.createdAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, AppTheme.rowVerticalPadding)
        .accessibilityLabel("\(task.title), expired")
    }
}
