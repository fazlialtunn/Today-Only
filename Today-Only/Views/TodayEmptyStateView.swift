//
//  TodayEmptyStateView.swift
//  Today-Only
//

import SwiftUI

struct TodayEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("No tasks for today")
                .font(.headline)

            Text("Add a task below to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
