import UserNotifications
import Foundation

enum NotificationManager {

    // MARK: - Permission

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Schedule

    /// Отменяет старые уведомления для привычки и планирует новые по её расписанию.
    static func schedule(for habit: Habit) {
        cancel(for: habit.id)
        guard let reminderTime = habit.reminderTime else { return }

        let calendar = Calendar.current
        let hour   = calendar.component(.hour,   from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)

        let weekdays: [Int]
        switch habit.frequency {
        case .daily:    weekdays = [1, 2, 3, 4, 5, 6, 7]
        case .weekdays: weekdays = [2, 3, 4, 5, 6]
        case .weekends: weekdays = [1, 7]
        }

        let content = UNMutableNotificationContent()
        content.title = habit.name
        content.body  = habit.isBad
            ? "Stay strong! Don't give in to temptation 💪"
            : "Time to complete your habit! Don't forget to mark it ✅"
        content.sound = .default

        for weekday in weekdays {
            var components = DateComponents()
            components.hour    = hour
            components.minute  = minute
            components.weekday = weekday

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id      = "\(habit.id.uuidString)-\(weekday)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { _ in }
        }
    }

    // MARK: - Cancel

    static func cancel(for habitID: UUID) {
        let ids = (1...7).map { "\(habitID.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
