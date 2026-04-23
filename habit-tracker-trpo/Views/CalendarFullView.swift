import SwiftUI
import SwiftData

struct CalendarFullView: View {
	@Binding var isMenuOpen: Bool
	@Query(sort: \Habit.createdAt) var habits: [Habit]

	@State private var displayedMonth: Date = Date()
	@State private var selectedDate: Date? = nil
	@State private var editingHabit: Habit? = nil

	private static let cal: Calendar = {
		var c = Calendar(identifier: .gregorian)
		c.firstWeekday = 2
		c.locale = Locale(identifier: "ru_RU")
		return c
	}()
	private var cal: Calendar { Self.cal }

	private let weekLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
	private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

	private var isCurrentMonth: Bool {
		cal.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
	}

	var body: some View {
		ZStack {
			Color(hex: "0A0E1A").ignoresSafeArea()
			VStack(spacing: 0) {
				topBar
				ScrollView(showsIndicators: false) {
					VStack(spacing: 16) {
						calendarCard
						if let date = selectedDate {
							dayDetailCard(date: date)
								.transition(.opacity.combined(with: .move(edge: .top)))
						}
						colorLegend
					}
					.padding(.horizontal, 16)
					.padding(.top, 12)
					.padding(.bottom, 36)
				}
			}
		}
		.sheet(item: $editingHabit) { habit in HabitDetailView(habit: habit) }
	}

	// MARK: - Top Bar

	private var topBar: some View {
		HStack {
			Button {
				withAnimation(.spring(duration: 0.3)) { isMenuOpen = true }
			} label: {
				Image(systemName: "line.3.horizontal")
					.foregroundStyle(.white)
					.font(.title2.weight(.medium))
					.frame(width: 44, height: 44)
			}
			Text("Мой прогресс")
				.font(.title2.bold()).foregroundStyle(.white)
			Spacer()
			if !isCurrentMonth {
				Button {
					withAnimation(.spring(duration: 0.3)) {
						displayedMonth = Date()
						selectedDate = Date()
					}
				} label: {
					Text("Сегодня")
						.font(.caption.weight(.semibold))
						.foregroundStyle(Color(hex: "4ADE80"))
						.padding(.horizontal, 10).padding(.vertical, 6)
						.background(Color(hex: "4ADE80").opacity(0.12))
						.clipShape(Capsule())
				}
				.transition(.opacity)
			}
		}
		.padding(.horizontal, 16).padding(.vertical, 8)
		.animation(.spring(duration: 0.2), value: isCurrentMonth)
	}

	// MARK: - Calendar Card

	private var calendarCard: some View {
		VStack(spacing: 12) {
			calendarHeader
			calendarGrid
		}
		.padding(16)
		.background(Color.white.opacity(0.05))
		.clipShape(RoundedRectangle(cornerRadius: 20))
	}

	private var calendarHeader: some View {
		HStack {
			Text(monthTitle)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(.white.opacity(0.7))
			Spacer()
			HStack(spacing: 8) {
				navButton(direction: -1, icon: "chevron.left")
				navButton(direction: 1,  icon: "chevron.right")
			}
		}
	}

	private var calendarGrid: some View {
		LazyVGrid(columns: columns, spacing: 8) {
			weekHeaderCells
			emptyOffsetCells
			dayCells
		}
	}

	private var weekHeaderCells: some View {
		ForEach(weekLabels, id: \.self) { label in
			Text(label)
				.font(.system(size: 11, weight: .semibold))
				.foregroundStyle(.white.opacity(0.3))
				.frame(maxWidth: .infinity)
		}
	}

	private var emptyOffsetCells: some View {
		ForEach(0..<firstDayOffset, id: \.self) { _ in
			Color.clear.frame(height: 44)
		}
	}

	private var dayCells: some View {
		ForEach(daysInMonth, id: \.self) { date in
			DayCell(
				date: date,
				// Исправление: только привычки которые существовали в этот день
				habits: habitsFor(date: date),
				calendar: cal,
				isSelected: selectedDate.map { cal.isDate($0, inSameDayAs: date) } ?? false
			)
			.onTapGesture {
				withAnimation(.spring(duration: 0.25)) {
					if let sel = selectedDate, cal.isDate(sel, inSameDayAs: date) {
						selectedDate = nil
					} else {
						selectedDate = date
					}
				}
			}
		}
	}

	// MARK: - Day Detail Card

	private func dayDetailCard(date: Date) -> some View {
		let relevantHabits = habitsFor(date: date)
		let completedHabits = relevantHabits.filter {  $0.isCompleted(on: date) }
		let missedHabits    = relevantHabits.filter { !$0.isCompleted(on: date) && !isFuture(date) }

		return VStack(alignment: .leading, spacing: 14) {
			Text(dayTitle(date))
				.font(.title3.bold()).foregroundStyle(.white)
				.padding(.horizontal, 4)

			if relevantHabits.isEmpty {
				Text(isFuture(date) ? "Этот день ещё впереди" : "Нет привычек на этот день")
					.font(.subheadline).foregroundStyle(.white.opacity(0.3))
					.padding(.horizontal, 4)
			} else if isFuture(date) {
				Text("Этот день ещё впереди")
					.font(.subheadline).foregroundStyle(.white.opacity(0.3))
					.padding(.horizontal, 4)
			} else {
				if !completedHabits.isEmpty {
					VStack(spacing: 8) {
						ForEach(completedHabits) { habitRow(habit: $0, done: true) }
					}
				}
				if !missedHabits.isEmpty {
					VStack(spacing: 8) {
						ForEach(missedHabits) { habitRow(habit: $0, done: false) }
					}
				}
				Text("\(completedHabits.count) из \(relevantHabits.count) привычек выполнено")
					.font(.caption).foregroundStyle(.white.opacity(0.3))
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.top, 4)
			}
		}
		.padding(16)
		.background(Color.white.opacity(0.05))
		.clipShape(RoundedRectangle(cornerRadius: 20))
	}

	private func habitRow(habit: Habit, done: Bool) -> some View {
		HStack(spacing: 12) {
			ZStack {
				Circle()
					.fill(Color(hex: habit.colorHex).opacity(done ? 0.2 : 0.08))
					.frame(width: 38, height: 38)
				Image(systemName: habit.iconName)
					.font(.callout)
					.foregroundStyle(Color(hex: habit.colorHex).opacity(done ? 1.0 : 0.4))
			}
			Text(habit.name)
				.font(.body.weight(.medium))
				.foregroundStyle(done ? .white : .white.opacity(0.35))
				.strikethrough(!done, color: .white.opacity(0.15))
			Spacer()
			Image(systemName: done ? "checkmark.circle.fill" : "circle")
				.foregroundStyle(done ? Color(hex: habit.colorHex) : .white.opacity(0.15))
				.font(.title3)
		}
		.padding(.horizontal, 12).padding(.vertical, 10)
		.background(Color.white.opacity(done ? 0.05 : 0.02))
		.clipShape(RoundedRectangle(cornerRadius: 14))
		.onTapGesture { editingHabit = habit }
	}

	// MARK: - Color Legend

	private var colorLegend: some View {
		HStack(spacing: 16) {
			legendItem(color: Color(hex: "4ADE80"), label: "Всё выполнено")
			legendItem(color: Color(hex: "FBBF24"), label: "Частично")
			legendItem(color: Color(hex: "F87171"), label: "Не выполнено")
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.padding(.vertical, 10).padding(.horizontal, 16)
		.background(Color.white.opacity(0.04))
		.clipShape(RoundedRectangle(cornerRadius: 14))
	}

	private func legendItem(color: Color, label: String) -> some View {
		HStack(spacing: 6) {
			Circle().fill(color).frame(width: 8, height: 8)
			Text(label).font(.caption2).foregroundStyle(.white.opacity(0.4))
		}
	}

	// MARK: - Nav Button

	private func navButton(direction: Int, icon: String) -> some View {
		Button {
			withAnimation(.spring(duration: 0.25)) {
				if let d = cal.date(byAdding: .month, value: direction, to: displayedMonth) {
					displayedMonth = d
				}
			}
		} label: {
			Image(systemName: icon)
				.font(.caption.weight(.semibold))
				.foregroundStyle(.white.opacity(0.5))
				.frame(width: 28, height: 28)
				.background(Color.white.opacity(0.07))
				.clipShape(Circle())
		}
	}

	// MARK: - Helpers

	// Привычки для конкретного дня: фильтр по createdAt + по дню недели
	private func habitsFor(date: Date) -> [Habit] {
		let weekday = cal.component(.weekday, from: date)
		let isWeekend = weekday == 1 || weekday == 7
		let dayStart = cal.startOfDay(for: date)

		return habits.filter { habit in
			// Привычка должна существовать в этот день
			guard cal.startOfDay(for: habit.createdAt) <= dayStart else { return false }
			switch habit.frequency {
			case .daily:    return true
			case .weekdays: return !isWeekend
			case .weekends: return isWeekend
			}
		}
	}

	private var monthTitle: String {
		let fmt = DateFormatter()
		fmt.locale = Locale(identifier: "ru_RU")
		fmt.dateFormat = "LLLL yyyy"
		return fmt.string(from: displayedMonth).capitalized
	}

	private var daysInMonth: [Date] {
		let comps = cal.dateComponents([.year, .month], from: displayedMonth)
		guard let firstDay = cal.date(from: comps),
			  let range = cal.range(of: .day, in: .month, for: displayedMonth)
		else { return [] }
		return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: firstDay) }
	}

	private var firstDayOffset: Int {
		let comps = cal.dateComponents([.year, .month], from: displayedMonth)
		guard let firstDay = cal.date(from: comps) else { return 0 }
		let weekday = cal.component(.weekday, from: firstDay)
		return (weekday - 2 + 7) % 7
	}

	private func isFuture(_ date: Date) -> Bool {
		cal.startOfDay(for: date) > cal.startOfDay(for: Date())
	}

	private func dayTitle(_ date: Date) -> String {
		let fmt = DateFormatter()
		fmt.locale = Locale(identifier: "ru_RU")
		fmt.dateFormat = "d MMMM"
		return fmt.string(from: date)
	}
}

// MARK: - Day Cell

private struct DayCell: View {
	let date: Date
	let habits: [Habit]
	let calendar: Calendar
	let isSelected: Bool

	private var dayNumber: Int { calendar.component(.day, from: date) }
	private var isToday: Bool { calendar.isDateInToday(date) }
	private var isFuture: Bool { calendar.startOfDay(for: date) > calendar.startOfDay(for: Date()) }

	private var completionRate: Double {
		guard !habits.isEmpty else { return -1 }
		let done = habits.filter { $0.isCompleted(on: date) }.count
		return Double(done) / Double(habits.count)
	}

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 10).fill(cellFill)
			if isSelected {
				RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 1.5)
			} else if isToday {
				RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "4ADE80"), lineWidth: 1.5)
			}
			VStack(spacing: 3) {
				Text("\(dayNumber)")
					.font(.system(size: 13, weight: isToday ? .bold : .regular))
					.foregroundStyle(textColor)
				if !isFuture && completionRate >= 0 {
					Circle().fill(dotColor).frame(width: 4, height: 4)
				}
			}
		}
		.frame(height: 44)
	}

	private var cellFill: Color {
		if isSelected        { return Color.white.opacity(0.12) }
		if isFuture          { return Color.clear }
		if completionRate < 0 { return Color.white.opacity(0.03) }
		if completionRate == 1.0 { return Color(hex: "4ADE80").opacity(0.2) }
		if completionRate > 0    { return Color(hex: "FBBF24").opacity(0.15) }
		return Color(hex: "F87171").opacity(0.1)
	}

	private var dotColor: Color {
		if completionRate < 0    { return .clear }
		if completionRate == 1.0 { return Color(hex: "4ADE80") }
		if completionRate > 0    { return Color(hex: "FBBF24") }
		return Color(hex: "F87171").opacity(0.6)
	}

	private var textColor: Color {
		if isFuture            { return .white.opacity(0.18) }
		if completionRate < 0  { return .white.opacity(0.25) }
		if completionRate == 1.0 { return Color(hex: "4ADE80") }
		if completionRate > 0    { return Color(hex: "FBBF24") }
		return Color(hex: "F87171").opacity(0.8)
	}
}

#Preview {
	let container: ModelContainer = {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: Habit.self, configurations: config)

		let context = container.mainContext

		let habit1 = Habit(
			name: "Спорт",
			colorHex: "4ADE80",
			iconName: "figure.run",
			frequency: .daily,
		)

		let habit2 = Habit(
			name: "Чтение",
			colorHex: "FBBF24",
			iconName: "book",
			frequency: .weekdays,
		)

		context.insert(habit1)
		context.insert(habit2)

		return container
	}()

	CalendarFullView(isMenuOpen: .constant(false))
		.modelContainer(container)
}
