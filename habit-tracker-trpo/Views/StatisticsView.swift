import SwiftUI
import SwiftData

struct StatisticsView: View {
	@Binding var isMenuOpen: Bool
	@Query(sort: \Habit.createdAt) var habits: [Habit]

	@State private var showBadHabits = false

	private var accentColor: Color {
		showBadHabits ? Color(hex: "F87171") : Color(hex: "4ADE80")
	}

	private var currentHabits: [Habit] {
		habits.filter { $0.isBad == showBadHabits }
	}

	var body: some View {
		ZStack {
			Color(hex: "0A0E1A").ignoresSafeArea()
			VStack(spacing: 0) {
				topBar
				if habits.isEmpty {
					Spacer()
					emptyState
					Spacer()
				} else {
					ScrollView(showsIndicators: false) {
						VStack(spacing: 20) {
							segmentPicker
							if currentHabits.isEmpty {
								noHabitsInCategory
							} else {
								chartSection
								statsCards
							}
						}
						.padding(.horizontal, 16)
						.padding(.top, 12)
						.padding(.bottom, 36)
					}
				}
			}
		}
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
			Text("Статистика")
				.font(.title2.bold()).foregroundStyle(.white)
			Spacer()
		}
		.padding(.horizontal, 16).padding(.vertical, 8)
	}

	// MARK: - Segment Picker

	private var segmentPicker: some View {
		HStack(spacing: 8) {
			segmentButton(title: "Полезные", isBad: false)
			segmentButton(title: "Вредные", isBad: true)
		}
		.padding(4)
		.background(Color.white.opacity(0.05))
		.clipShape(RoundedRectangle(cornerRadius: 14))
	}

	private func segmentButton(title: String, isBad: Bool) -> some View {
		let isSelected = showBadHabits == isBad
		let color: Color = isBad ? Color(hex: "F87171") : Color(hex: "4ADE80")
		return Button {
			withAnimation(.spring(duration: 0.25)) { showBadHabits = isBad }
		} label: {
			Text(title)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(isSelected ? color : .white.opacity(0.35))
				.frame(maxWidth: .infinity)
				.padding(.vertical, 10)
				.background(isSelected ? color.opacity(0.12) : Color.clear)
				.clipShape(RoundedRectangle(cornerRadius: 10))
		}
		.buttonStyle(.plain)
	}

	// MARK: - Chart

	private var chartData: [(day: Int, count: Int)] {
		let calendar = Calendar.current
		let today = Date()
		let comps = calendar.dateComponents([.year, .month], from: today)
		guard let monthStart = calendar.date(from: comps) else { return [] }
		let daysPassed = calendar.component(.day, from: today)

		return (0..<daysPassed).compactMap { offset in
			guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { return nil }
			let dayStart = calendar.startOfDay(for: date)
			let count = currentHabits.filter {
				calendar.startOfDay(for: $0.createdAt) <= dayStart && $0.isCompleted(on: date)
			}.count
			return (day: offset + 1, count: count)
		}
	}

	private var maxCount: Int {
		max(chartData.map { $0.count }.max() ?? 0, currentHabits.count, 1)
	}

	private var chartSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(showBadHabits ? "Срывов за месяц" : "Выполнено привычек за месяц")
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(.white.opacity(0.5))

			customBarChart
				.frame(height: 180)
				.padding(14)
				.background(Color.white.opacity(0.04))
				.clipShape(RoundedRectangle(cornerRadius: 16))
		}
	}

	private var customBarChart: some View {
		GeometryReader { geo in
			let totalBars = chartData.count
			guard totalBars > 0 else { return AnyView(EmptyView()) }

			let chartHeight = geo.size.height - 20
			let barAreaWidth = geo.size.width / CGFloat(totalBars)
			let barWidth = max(barAreaWidth * 0.55, 2)

			return AnyView(
				ZStack(alignment: .bottomLeading) {
					// Сетка
					VStack(spacing: 0) {
						ForEach(0..<4) { _ in
							Spacer()
							Rectangle()
								.fill(Color.white.opacity(0.07))
								.frame(height: 1)
						}
					}
					.frame(height: chartHeight)
					.frame(maxWidth: .infinity)

					// Столбцы + подписи
					HStack(alignment: .bottom, spacing: 0) {
						ForEach(chartData, id: \.day) { point in
							let ratio = maxCount > 0 ? CGFloat(point.count) / CGFloat(maxCount) : 0
							let barH = max(ratio * chartHeight, point.count > 0 ? 4 : 0)

							VStack(spacing: 4) {
								Spacer(minLength: 0)
								RoundedRectangle(cornerRadius: 3)
									.fill(barFill(for: point.count))
									.frame(width: barWidth, height: barH)
								if point.day == 1 || point.day % 5 == 0 {
									Text("\(point.day)")
										.font(.system(size: 9))
										.foregroundStyle(.white.opacity(0.3))
										.frame(height: 14)
								} else {
									Color.clear.frame(height: 14)
								}
							}
							.frame(width: barAreaWidth)
						}
					}
				}
			)
		}
	}

	private func barFill(for count: Int) -> Color {
		guard count > 0 else { return Color.white.opacity(0.07) }
		if showBadHabits {
			// Для вредных: чем больше срывов — тем краснее
			return count == currentHabits.count
				? Color(hex: "F87171").opacity(0.9)
				: Color(hex: "FBBF24").opacity(0.75)
		} else {
			return count == currentHabits.count
				? Color(hex: "4ADE80").opacity(0.85)
				: Color(hex: "FBBF24").opacity(0.75)
		}
	}

	// MARK: - Stats Cards

	private var statsCards: some View {
		let todayCount = currentHabits.filter { $0.isCompleted(on: .now) }.count
		let bestStreakHabit = currentHabits.max(by: { $0.bestStreak < $1.bestStreak })

		return HStack(spacing: 10) {
			if showBadHabits {
				statCard(
					title: "Сегодня",
					value: "\(todayCount)/\(currentHabits.count)",
					unit: "срывов",
					icon: "exclamationmark.circle.fill",
					color: todayCount == 0
						? Color(hex: "4ADE80")
						: Color(hex: "F87171")
				)
				statCard(
					title: "Серия без срывов",
					value: "\(bestStreakHabit.map { daysWithout($0) } ?? 0)",
					unit: "дней",
					icon: "shield.fill",
					color: Color(hex: "60A5FA")
				)
				statCard(
					title: "Всего срывов",
					value: "\(currentHabits.reduce(0) { $0 + $1.completionDates.count })",
					unit: "за всё время",
					icon: "flame.fill",
					color: Color(hex: "FB923C")
				)
			} else {
				statCard(
					title: "Сегодня",
					value: "\(todayCount)/\(currentHabits.count)",
					unit: "привычек",
					icon: "checkmark.circle.fill",
					color: todayCount == currentHabits.count && currentHabits.count > 0
						? Color(hex: "4ADE80")
						: Color(hex: "60A5FA")
				)
				statCard(
					title: "Серия",
					value: "\(bestStreakHabit?.currentStreak ?? 0)",
					unit: "дней",
					icon: "flame.fill",
					color: Color(hex: "FB923C")
				)
				statCard(
					title: "Рекорд",
					value: "\(bestStreakHabit?.bestStreak ?? 0)",
					unit: "дней подряд",
					icon: "trophy.fill",
					color: Color(hex: "FBBF24")
				)
			}
		}
	}

	// Количество дней подряд без срывов для вредной привычки
	private func daysWithout(_ habit: Habit) -> Int {
		let calendar = Calendar.current
		var streak = 0
		var checkDate = calendar.startOfDay(for: Date())
		while true {
			if habit.isCompleted(on: checkDate) { break }
			streak += 1
			guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
			// Не уходим раньше создания привычки
			if prev < calendar.startOfDay(for: habit.createdAt) { break }
			checkDate = prev
		}
		return streak
	}

	private func statCard(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
		VStack(spacing: 8) {
			Image(systemName: icon).font(.title3).foregroundStyle(color)
			Text(value).font(.title2.bold()).foregroundStyle(.white)
			VStack(spacing: 2) {
				Text(title).font(.caption2.weight(.semibold)).foregroundStyle(.white.opacity(0.4))
				Text(unit).font(.caption2).foregroundStyle(.white.opacity(0.25))
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 16)
		.background(Color.white.opacity(0.05))
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.15), lineWidth: 1))
	}

	// MARK: - Empty / No habits in category

	private var noHabitsInCategory: some View {
		VStack(spacing: 14) {
			Image(systemName: showBadHabits ? "exclamationmark.circle" : "sparkles")
				.font(.system(size: 40))
				.foregroundStyle(accentColor.opacity(0.4))
			Text(showBadHabits ? "Нет вредных привычек" : "Нет полезных привычек")
				.font(.headline).foregroundStyle(.white.opacity(0.4))
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 48)
	}

	private var emptyState: some View {
		VStack(spacing: 14) {
			Image(systemName: "chart.bar.xaxis")
				.font(.system(size: 40))
				.foregroundStyle(Color(hex: "4ADE80").opacity(0.4))
			Text("Нет привычек").font(.headline).foregroundStyle(.white.opacity(0.4))
			Text("Сначала добавь привычку").font(.caption).foregroundStyle(.white.opacity(0.2))
		}
	}
}
