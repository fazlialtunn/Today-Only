//
//  Today_OnlyApp.swift
//  Today-Only
//
//  Created by Fazlı Altun on 15.05.2026.
//

import SwiftUI

@main
struct Today_OnlyApp: App {
    private let viewModel = TodayTodoViewModel(
        store: TodoTaskStore(),
        dateProvider: SystemDateProvider()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
