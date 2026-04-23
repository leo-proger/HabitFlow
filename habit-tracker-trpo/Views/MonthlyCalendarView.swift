import SwiftUI

struct MonthlyCalendarView: View {
	let habits: [Habit]
	@Binding var displayedMonth: Date

	@State private var slideProgress: CGFloat = 0
	@State private var shadowMonth: Date? = nil
	@State private var goingForward = true
	@State private var isAnimating = false

	private static let cal: Calendar = {
		var c = Calendar(identifier: .gregorian)
		c.firstWeekday = 2
		c.locale = Locale(identifier: "ru_RU")
		return c
	}()
	private var cal: Calendar { Self.cal }

	private let weekLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
	private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

	private var isCurrentMonth: Bool {
		cal.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
	}

	var body: some View {
		VStack(spacing: 10) {
			header

			LazyVGrid(columns: columns, spacing: 4) {
				ForEach(weekLabels, id: \.self) { label in
					Text(label)
						.font(.system(size: 10, weight: .semibold))
						.foregroundStyle(.white.opacity(0.3))
						.frame(maxWidth: .infinity)
				}
			}

			GeometryReader { geo in
				let w = geo.size.width
				ZStack(alignment: .topLeading) {
					dayGrid(for: displayedMonth, width: w)
						.offset(x: outgoingOffset(width: w))

					if let shadow = shadowMonth {
						dayGrid(for: shadow, width: w)
							.offset(x: incomingOffset(width: w))
					}
				}
			}
			.frame(height: 200)
			.clipped()
		}
		.padding(16)
		.background(Color.white.opacity(0.05))
		.clipShape(RoundedRectangle(cornerRadius: 20))
		// Свайп убран — только кнопки
	}

	// MARK: - Offsets

	private func outgoingOffset(width: CGFloat) -> CGFloat {
		guard isAnimating else { return 0 }
		return goingForward ? -(slideProgress * width) : (slideProgress * width)
	}

	private func incomingOffset(width: CGFloat) -> CGFloat {
		guard isAnimating else { return 0 }
		return goingForward
			?  width - (slideProgress * width)
			: -width + (slideProgress * width)
	}

	// MARK: - Day Grid

	@ViewBuilder
	private func dayGrid(for month: Date, width: CGFloat) -> some View {
		LazyVGrid(columns: columns, spacing: 4) {
			ForEach(0..<firstDayOffset(for: month), id: \.self) { _ in
				Color.clear.frame(height: 30)
			}
			ForEach(daysIn(month: month), id: \.self) { date in
				SmallDayCell(
					date: date,
					habits: habits.filter {
						cal.startOfDay(for: $0.createdAt) <= cal.startOfDay(for: date)
					},
					calendar: cal
				)
			}
		}
		.frame(width: width, alignment: .topLeading)
	}

	// MARK: - Header

	private var header: some View {
		HStack {
			Text(monthTitle(for: displayedMonth))
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(.white)
			Spacer()
			if !isCurrentMonth {
				Button {
					guard !isAnimating else { return }
					withAnimation(.easeOut(duration: 0.2)) { displayedMonth = Date() }
				} label: {
					Text("Сегодня")
						.font(.caption2.weight(.semibold))
						.foregroundStyle(Color(hex: "4ADE80"))
						.padding(.horizontal, 8).padding(.vertical, 4)
						.background(Color(hex: "4ADE80").opacity(0.12))
						.clipShape(Capsule())
				}
				.buttonStyle(.borderless)
				.transition(.opacity)
			}
			HStack(spacing: 6) {
				navButton(direction: -1, icon: "chevron.left")
				navButton(direction:  1, icon: "chevron.right")
			}
		}
		.animation(.easeOut(duration: 0.2), value: isCurrentMonth)
	}

	private func navButton(direction: Int, icon: String) -> some View {
		Button { navigate(by: direction) } label: {
			Image(systemName: icon)
				.font(.caption.weight(.semibold))
				.foregroundStyle(.white.opacity(0.5))
				.frame(width: 28, height: 28)
				.background(Color.white.opacity(0.07))
				.clipShape(Circle())
		}
		.buttonStyle(.borderless)
	}

	// MARK: - Navigation

	private func navigate(by value: Int) {
		guard !isAnimating,
			  let newMonth = cal.date(byAdding: .month, value: value, to: displayedMonth)
		else { return }

		isAnimating   = true
		goingForward  = value > 0
		shadowMonth   = newMonth
		slideProgress = 0

		withAnimation(.easeInOut(duration: 0.32)) {
			slideProgress = 1.0
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
			displayedMonth = newMonth
			shadowMonth    = nil
			slideProgress  = 0
			isAnimating    = false
		}
	}

	// MARK: - Helpers

	private func monthTitle(for month: Date) -> String {
		let fmt = DateFormatter()
		fmt.locale = Locale(identifier: "ru_RU")
		fmt.dateFormat = "LLLL yyyy"
		return fmt.string(from: month).capitalized
	}

	private func firstDayOffset(for month: Date) -> Int {
		let comps = cal.dateComponents([.year, .month], from: month)
		guard let firstDay = cal.date(from: comps) else { return 0 }
		let weekday = cal.component(.weekday, from: firstDay)
		return (weekday - 2 + 7) % 7
	}

	private func daysIn(month: Date) -> [Date] {
		let comps = cal.dateComponents([.year, .month], from: month)
		guard let firstDay = cal.date(from: comps),
			  let range = cal.range(of: .day, in: .month, for: month)
		else { return [] }
		return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: firstDay) }
	}
}

// MARK: - Small Day Cell

private struct SmallDayCell: View {
	let date: Date
	let habits: [Habit]
	let calendar: Calendar

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
			RoundedRectangle(cornerRadius: 6).fill(cellFill)
			if isToday {
				RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "4ADE80"), lineWidth: 1.5)
			}
			Text("\(dayNumber)")
				.font(.system(size: 11, weight: isToday ? .bold : .regular))
				.foregroundStyle(textColor)
		}
		.frame(height: 30)
	}

	private var cellFill: Color {
		if isFuture            { return .clear }
		if completionRate < 0  { return Color.white.opacity(0.03) }
		if completionRate == 1 { return Color(hex: "4ADE80").opacity(0.2) }
		if completionRate > 0  { return Color(hex: "FBBF24").opacity(0.15) }
		return Color(hex: "F87171").opacity(0.1)
	}

	private var textColor: Color {
		if isFuture            { return .white.opacity(0.18) }
		if completionRate < 0  { return .white.opacity(0.2) }
		if completionRate == 1 { return Color(hex: "4ADE80") }
		if completionRate > 0  { return Color(hex: "FBBF24") }
		return Color(hex: "F87171").opacity(0.7)
	}
}
