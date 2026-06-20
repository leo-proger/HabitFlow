//
//  Habit.swift
//  habit-flow
//
//  Created by Leo Proger on 3/17/2026.
//

import Foundation
import SwiftData

// @Model — макрос SwiftData. Превращает class в модель с персистентностью.
// Под капотом добавляет @Observable (реактивность) и логику сохранения в БД.
// final — класс нельзя наследовать (помогает компилятору оптимизировать)
@Model
final class Habit {
	// SwiftData требует, чтобы свойства имели default value ИЛИ были установлены в init
	var id: UUID = UUID()
	var name: String = ""
	var habitDescription: String = ""
	var colorHex: String = "4ADE80"
	var iconName: String = "star.fill"
	var frequencyRaw: String = Frequency.daily.rawValue  // храним строку — SwiftData проще с примитивами
	var reminderTime: Date? = nil  // ? означает Optional — может быть nil
	var createdAt: Date = Date()
	var completionDates: [Date] = []  // SwiftData умеет хранить массивы Codable-типов
	var isBad: Bool = false

	// Кастомный init — обратите внимание на default values в параметрах (как в Python)
	init(
		name: String,
		habitDescription: String = "",
		colorHex: String = "4ADE80",
		iconName: String = "star.fill",
		frequency: Frequency = .daily,
		reminderTime: Date? = nil,
		isBad: Bool = false
	) {
		self.id = UUID()
		self.name = name
		self.habitDescription = habitDescription
		self.colorHex = colorHex
		self.iconName = iconName
		self.frequencyRaw = frequency.rawValue
		self.reminderTime = reminderTime
		self.createdAt = Date()
		self.completionDates = []
		self.isBad = isBad
	}

	// MARK: - Nested enum
	// CaseIterable — автоматически добавляет свойство .allCases: [Frequency]
	enum Frequency: String, CaseIterable {
		case daily = "Каждый день"
		case weekdays = "По будням"
		case weekends = "По выходным"
	}

	// Computed property для работы с enum вместо сырой строки
	// get/set — как в Python property с @getter/@setter
	var frequency: Frequency {
		get { Frequency(rawValue: frequencyRaw) ?? .daily}
		set { frequencyRaw = newValue.rawValue }
	}

	// MARK: - Completion Logic

	func isCompleted(on date: Date) -> Bool {
		let calendar = Calendar.current
		// contains(where:) — как stream().anyMatch() в Java / any() в Python
		return completionDates.contains {
			calendar.isDate($0, inSameDayAs: date)
		}
		// $0 — первый аргумент замыкания (сокращённый синтаксис)
	}

	func toggleCompletion(on date: Date) {
		let calendar = Calendar.current
		// firstIndex(where:) возвращает Optional<Int>
		if let index = completionDates.firstIndex(where: {
			calendar.isDate($0, inSameDayAs: date)
		}) {
			completionDates.remove(at: index)
		} else {
			completionDates.append(date)
		}
	}

	// Текущая серия (streak)
	var currentStreak: Int {
		let calendar = Calendar.current
		var streak = 0
		var checkDate = Date()

		// Если сегодня не выполнено — начинаем со вчера
		if !isCompleted(on: checkDate) {
			guard
				let yesterday = calendar.date(
					byAdding: .day,
					value: -1,
					to: checkDate
				),
				isCompleted(on: yesterday)
			else { return 0 }
			// guard let — если выражение == nil, выполняем else { return }
			checkDate = yesterday
		}

		while isCompleted(on: checkDate) {
			streak += 1
			guard
				let previousDay = calendar.date(
					byAdding: .day,
					value: -1,
					to: checkDate
				)
			else { break }
			checkDate = previousDay
		}
		return streak
	}

	// Процент выполнения за текущий месяц (до сегодня)
	var monthlyCompletionRate: Double {
		let calendar = Calendar.current
		let today = Date()
		let components = calendar.dateComponents([.year, .month], from: today)
		guard let monthStart = calendar.date(from: components) else { return 0 }

		let daysPassed = calendar.component(.day, from: today)
		var completed = 0

		for day in 0..<daysPassed {
			if let date = calendar.date(
				byAdding: .day,
				value: day,
				to: monthStart
			),
				isCompleted(on: date)
			{
				completed += 1
			}
		}
		return daysPassed > 0 ? Double(completed) / Double(daysPassed) : 0
	}
	
	// Лучшая серия за всё время
	var bestStreak: Int {
		let calendar = Calendar.current
		guard !completionDates.isEmpty else { return 0 }
		
		let sorted = completionDates
			.map { calendar.startOfDay(for: $0) }
			.sorted()
		
		var best = 1
		var current = 1
		
		for i in 1..<sorted.count {
			let diff = calendar.dateComponents([.day], from: sorted[i-1], to: sorted[i]).day ?? 0
			if diff == 1 {
				current += 1
				best = max(best, current)
			} else if diff > 1 {
				current = 1
			}
		}
		return best
	}

	// Данные для графика: массив (день, выполнено) за текущий месяц
	func chartData() -> [(day: Int, completed: Double)] {
		let calendar = Calendar.current
		let today = Date()
		let comps = calendar.dateComponents([.year, .month], from: today)
		guard let monthStart = calendar.date(from: comps) else { return [] }
		
		let daysPassed = calendar.component(.day, from: today)
		
		return (0..<daysPassed).compactMap { offset in
			guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { return nil }
			return (day: offset + 1, completed: isCompleted(on: date) ? 1.0 : 0.0)
		}
	}
}
