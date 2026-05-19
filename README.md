# Today-Only Todo App

Eulerity iOS Internship take-home a SwiftUI app where tasks exist only for the current calendar day.

## 1. Overall Approach

The app follows **SwiftUI + MVVM** with a small service layer:

- **Views** — UI, animations, haptics, and semantic theming
- **`TodayTodoViewModel`** — task list state, validation, and coordination with storage/notifications
- **Services** — persistence (`TodoTaskStore`), day filtering (`TodayTaskFilter`), expiration validation, and local notifications (`NotificationScheduler`)

**Today-only constraint:** Tasks are stored in a single JSON file, but the UI only shows tasks that pass `TodayTaskFilter`: created on the current calendar day and not yet expired. Tasks from previous days remain on disk but are treated as expired and hidden from the main list (viewable via “Show expired”).

**Time and expiration:** A injectable `DateProviding` abstraction (`SystemDateProvider` / `FixedDateProvider`) supplies `now()` and `Calendar` for tests. Tasks may include an optional same-day `expiresAt`; otherwise they are valid until end of day. Expiration is evaluated at load/refresh time—no background jobs. Optional local notifications fire 10 minutes before expiration.

## 2. Key Decisions and Tradeoffs

**Filtering instead of deletion** — Expired and prior-day tasks stay in JSON; visibility is computed when loading. This keeps persistence simple, avoids destructive midnight logic, and matches “today-only” as a display rule rather than data loss.

**Tasks tied to the current day** — `createdAt` defines the task’s day. There is no backlog, overdue list, or carry-forward—aligned with the exercise scope and keeps the mental model clear.

**No future scheduling** — Users cannot pick future dates; `expiresAt` must be the same day as `createdAt` and after `now`. This avoids partial calendar/scheduling features the spec does not require.

**Intentional simplifications** — JSON file storage instead of Core Data/SwiftData; a single main screen (no navigation stack); notification scheduling delegated to a thin service; unit tests focused on ViewModel and date logic rather than UI tests.

## 3. What I Would Improve With More Time

- **Widgets / App Intents** — quick add and today’s task count from the Home Screen
- **Notification polish** — deep link to a task, reschedule on edit, badge cleanup
- **Broader test coverage** — store integration tests, timezone/DST edge cases, UI tests
- **UI polish** — swipe-to-delete, task reordering, accessibility audit

## 4. Challenges and How I Solved Them

**Date/time logic** — Centralized day boundaries in `Calendar.endOfDay`, `TodayTaskFilter`, and `TaskExpirationValidator` so rules are not duplicated across views and storage.

**Expiration without background jobs** — Tasks disappear when `reloadTasks()` or `refreshExpiredTasks()` runs (on appear, foreground, and a lightweight timer). Expiration is derived from `now`, not from scheduled deletion.

**Testable time** — `DateProviding` and `FixedDateProvider` allow unit tests to simulate “today,” “yesterday,” and expiration without changing the system clock.

**Same-day notification timing** — `TaskNotificationReminderCalculator` ensures reminders are only scheduled for today, never in the past, and cancelled when a task is completed. Permission is requested on launch; denied permission fails silently.

**Preserving history while keeping the main list clean** — Partitioning into `visibleTasks` and `expiredTasks` let prior-day and time-expired tasks remain stored but out of the primary workflow.
