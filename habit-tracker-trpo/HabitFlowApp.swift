import SwiftData
import SwiftUI

@main
struct HabitFlowApp: App {
    init() {
        NotificationManager.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Habit.self)
    }
}
