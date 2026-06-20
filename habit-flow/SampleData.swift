//
//  SampleData.swift
//  habit-flow
//
//  Демо-данные для красивых скриншотов.
//  Сидер срабатывает только если база пустая, поэтому реальные данные не затираются.
//  Чтобы отключить — убери вызов SampleData.seedIfNeeded(...) в HabitFlowApp
//  и удали этот файл (предварительно один раз удалив приложение из симулятора,
//  чтобы очистить уже засеянную базу).
//

import Foundation
import SwiftData

enum SampleData {

    /// Засеять демо-привычки, если в базе ещё ничего нет.
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<Habit>())) ?? 0
        guard existing == 0 else { return }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        func date(daysAgo: Int) -> Date {
            cal.date(byAdding: .day, value: -daysAgo, to: today) ?? today
        }
        func reminder(hour: Int) -> Date {
            cal.date(bySettingHour: hour, minute: 0, second: 0, of: today) ?? today
        }

        // Описание одной демо-привычки
        struct Demo {
            let name: String
            let description: String
            let color: String
            let icon: String
            let frequency: Habit.Frequency
            let isBad: Bool
            let reminderHour: Int?
            let streak: Int      // текущая серия (дней подряд от сегодня)
            let missEvery: Int   // как часто пропускаем после серии (больше = выше процент)
        }

        let demos: [Demo] = [
            Demo(name: "Meditation", description: "10 minutes of mindfulness",
                 color: "A78BFA", icon: "brain.head.profile", frequency: .daily,
                 isBad: false, reminderHour: 8, streak: 14, missEvery: 12),
            Demo(name: "Reading", description: "30 pages before bed",
                 color: "60A5FA", icon: "book.fill", frequency: .daily,
                 isBad: false, reminderHour: 21, streak: 6, missEvery: 8),
            Demo(name: "Workout", description: "Strength or cardio",
                 color: "FB923C", icon: "dumbbell.fill", frequency: .daily,
                 isBad: false, reminderHour: 18, streak: 3, missEvery: 4),
            Demo(name: "Morning Run", description: "5 km on weekdays",
                 color: "4ADE80", icon: "figure.walk", frequency: .weekdays,
                 isBad: false, reminderHour: 7, streak: 8, missEvery: 6),
            Demo(name: "Glass of Water", description: "Right after waking up",
                 color: "34D399", icon: "drop.fill", frequency: .daily,
                 isBad: false, reminderHour: nil, streak: 5, missEvery: 7),
            Demo(name: "No Evening Coffee", description: "No coffee after 4 PM",
                 color: "F87171", icon: "cup.and.saucer.fill", frequency: .daily,
                 isBad: true, reminderHour: 16, streak: 4, missEvery: 5),
        ]

        let totalDays = 40  // глубина истории — покрывает текущий месяц и часть прошлого

        for demo in demos {
            let habit = Habit(
                name: demo.name,
                habitDescription: demo.description,
                colorHex: demo.color,
                iconName: demo.icon,
                frequency: demo.frequency,
                reminderTime: demo.reminderHour.map { reminder(hour: $0) },
                isBad: demo.isBad
            )
            habit.createdAt = date(daysAgo: totalDays)
            habit.completionDates = completionPattern(
                streak: demo.streak,
                totalDays: totalDays,
                missEvery: demo.missEvery
            ).map { date(daysAgo: $0) }
            context.insert(habit)
        }

        try? context.save()
    }

    /// Смещения в днях (0 = сегодня), которые считаем выполненными.
    /// Первые `streak` дней идут подряд (текущая серия), дальше — с периодическими пропусками.
    private static func completionPattern(streak: Int, totalDays: Int, missEvery: Int) -> [Int] {
        var offsets: [Int] = []
        for offset in 0..<totalDays {
            if offset < streak {
                offsets.append(offset)
            } else if (offset - streak) % max(missEvery, 2) != 0 {
                offsets.append(offset)
            }
        }
        return offsets
    }
}
