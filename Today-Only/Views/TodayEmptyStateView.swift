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
                .foregroundStyle(Color(.secondaryLabel))
                .symbolRenderingMode(.hierarchical)

            Text("No tasks for today")
                .font(.headline)
                .foregroundStyle(Color(.label))

            Text("Add a task below to get started.")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
