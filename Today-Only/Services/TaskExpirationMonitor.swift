//
//  TaskExpirationMonitor.swift
//  Today-Only
//

import Combine
import Foundation

/// Lightweight periodic and one-shot timers for re-applying expiration filters.
@MainActor
final class TaskExpirationMonitor {
    private var periodicCancellable: AnyCancellable?
    private var oneShotWorkItem: DispatchWorkItem?
    private let interval: TimeInterval

    init(interval: TimeInterval = 30) {
        self.interval = interval
    }

    func startPeriodic(onTick: @escaping () -> Void) {
        stopPeriodic()
        periodicCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in onTick() }
    }

    func stopPeriodic() {
        periodicCancellable?.cancel()
        periodicCancellable = nil
    }

    func scheduleOneShot(after delay: TimeInterval, onTick: @escaping () -> Void) {
        cancelOneShot()
        guard delay > 0 else {
            onTick()
            return
        }
        let work = DispatchWorkItem(block: onTick)
        oneShotWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    func cancelOneShot() {
        oneShotWorkItem?.cancel()
        oneShotWorkItem = nil
    }

    func stopAll() {
        stopPeriodic()
        cancelOneShot()
    }
}
