import SwiftData
import SwiftUI

@main
struct HabitFlowApp: App {
    let container: ModelContainer

    init() {
        NotificationManager.requestPermission()
        do {
            container = try ModelContainer(for: Habit.self)
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
        // Демо-данные для скриншотов (засеваются только в пустую базу)
        SampleData.seedIfNeeded(container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
