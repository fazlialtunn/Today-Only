//
//  ExpiredTaskRowView.swift
//  Today-Only
//

import SwiftUI

struct ExpiredTaskRowView: View {
    let task: TodoTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.xmark")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .strikethrough(true, color: .secondary)

                Text(task.createdAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(0.7)
        .accessibilityLabel("\(task.title), expired")
    }
}
