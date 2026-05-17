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
                .foregroundStyle(Color(.tertiaryLabel))

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(Color(.secondaryLabel))
                    .strikethrough(true, color: Color(.tertiaryLabel))

                Text(task.createdAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(0.75)
        .accessibilityLabel("\(task.title), expired")
    }
}
