//
//  TodayHeaderView.swift
//  Today-Only
//

import SwiftUI

struct TodayHeaderView: View {
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today")
                .font(.largeTitle.bold())
                .foregroundStyle(Color(.label))

            Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(AppTheme.screenBackground)
    }
}
