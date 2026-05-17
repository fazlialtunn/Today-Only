//
//  HapticFeedback.swift
//  Today-Only
//
//  UI-layer haptics only. Reuses prepared generators for efficiency.
//

import UIKit

enum HapticFeedback {
    private static let successFeedback = UINotificationFeedbackGenerator()
    private static let toggleFeedback = UIImpactFeedbackGenerator(style: .light)

    static func prepareGenerators() {
        successFeedback.prepare()
        toggleFeedback.prepare()
    }

    static func taskAdded() {
        successFeedback.notificationOccurred(.success)
        successFeedback.prepare()
    }

    static func taskToggled() {
        toggleFeedback.impactOccurred()
        toggleFeedback.prepare()
    }
}
