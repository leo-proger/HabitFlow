import SwiftUI
import SwiftData

struct SnapPressStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
			.brightness(configuration.isPressed ? -0.06 : 0)
			.animation(.spring(response: 0.2, dampingFraction: 0.65), value: configuration.isPressed)
	}
}

struct HabitListView: View {
	@Binding var isMenuOpen: Bool
	@Query(sort: \Habit.createdAt) var habits: [Habit]
	@Environment(\.modelContext) private var modelContext

	@State private var showAddHabit    = false
	@State private var selectedHabit: Habit? = nil
	@State private var habitToDelete: Habit? = nil
	@State private var pressedHabitId: UUID? = nil
	@State private var calendarMonth: Date = Date()
	@State private var showBadHabits: Bool = false

	private var accentColor: Color {
		showBadHabits ? Color(hex: "F87171") : Color(hex: "4ADE80")
	}

	private var currentHabits: [Habit] {
		habits.filter { $0.isBad == showBadHabits }
	}

	private var sortedHabits: [Habit] {
		let today = Calendar.current.startOfDay(for: Date())
		return currentHabits.sorted { a, b in
			let aDone = a.isCompleted(on: .now)
			let bDone = b.isCompleted(on: .now)
			if aDone != bDone { return !aDone }
			if aDone && bDone {
				let aTime = a.completionDates.filter { $0 >= today }.max() ?? today
				let bTime = b.completionDates.filter { $0 >= today }.max() ?? today
				return aTime > bTime
			}
			return a.createdAt < b.createdAt
		}
	}

	var body: some View {
		ZStack {
			Color(hex: "0A0E1A").ignoresSafeArea()
			VStack(spacing: 0) {
				topBar
				List {
					ForEach(sortedHabits) { habit in
						HabitRowView(habit: habit, isPressed: pressedHabitId == habit.id)
							.listRowBackground(Color.clear)
							.listRowSeparator(.hidden)
							.listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
							.onLongPressGesture(minimumDuration: 0.45, pressing: { isPressing in
								withAnimation(.spring(response: 0.2, dampingFraction: 0.65)) {
									pressedHabitId = isPressing ? habit.id : nil
								}
							}) {
								pressedHabitId = nil
								UIImpactFeedbackGenerator(style: .light).impactOccurred()
								selectedHabit = habit
							}
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								Button(role: .destructive) {
									habitToDelete = habit
								} label: {
									Label("Удалить", systemImage: "trash.fill")
								}
							}
					}

					addButton
						.listRowBackground(Color.clear)
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))

					if !currentHabits.isEmpty {
						MonthlyCalendarView(habits: currentHabits, displayedMonth: $calendarMonth)
							.listRowBackground(Color.clear)
							.listRowSeparator(.hidden)
							.listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
					}

					if currentHabits.isEmpty {
						emptyState
							.listRowBackground(Color.clear)
							.listRowSeparator(.hidden)
					}

					switchModeButton
						.listRowBackground(Color.clear)
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 36, trailing: 16))
				}
				.listStyle(.plain)
				.scrollContentBackground(.hidden)
			}
		}
		.sheet(isPresented: $showAddHabit) { AddHabitView(isBad: showBadHabits) }
		.sheet(item: $selectedHabit) { habit in HabitDetailView(habit: habit) }
		.alert(
			"Удалить привычку?",
			isPresented: Binding(
				get: { habitToDelete != nil },
				set: { if !$0 { habitToDelete = nil } }
			)
		) {
			Button("Удалить", role: .destructive) {
				if let h = habitToDelete { modelContext.delete(h); habitToDelete = nil }
			}
			Button("Отмена", role: .cancel) { habitToDelete = nil }
		} message: {
			if let h = habitToDelete {
				Text("Привычка «\(h.name)» и весь её прогресс будут удалены безвозвратно.")
			}
		}
	}

	// MARK: - Top Bar

	private var topBar: some View {
		HStack(spacing: 12) {
			Button {
				withAnimation(.spring(duration: 0.3)) { isMenuOpen = true }
			} label: {
				Image(systemName: "line.3.horizontal")
					.foregroundStyle(.white)
					.font(.title2.weight(.medium))
					.frame(width: 44, height: 44)
			}
			Text(showBadHabits ? "Мои вредные привычки" : "Мои привычки")
				.font(.title2.bold()).foregroundStyle(.white)
			Spacer()
			progressRing
		}
		.padding(.horizontal, 16).padding(.vertical, 8)
		.animation(.spring(duration: 0.2), value: showBadHabits)
	}

	// MARK: - Progress Ring

	private var progressRing: some View {
		ZStack {
			Circle().stroke(Color.white.opacity(0.1), lineWidth: 3.5)
			Circle()
				.trim(from: 0, to: CGFloat(todayRate))
				.stroke(accentColor, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.spring(duration: 0.5), value: todayRate)
			Text("\(Int(todayRate * 100))%")
				.font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
		}
		.frame(width: 42, height: 42)
	}

	// MARK: - Empty State

	private var emptyState: some View {
		VStack(spacing: 14) {
			Image(systemName: showBadHabits ? "exclamationmark.circle" : "sparkles")
				.font(.system(size: 40))
				.foregroundStyle(accentColor.opacity(0.5))
			Text(showBadHabits ? "Добавь первую вредную привычку" : "Добавь первую привычку")
				.font(.headline).foregroundStyle(.white.opacity(0.5))
			Text(showBadHabits ? "Осознанность — первый шаг к изменениям" : "Маленькие шаги — большие перемены")
				.font(.caption).foregroundStyle(.white.opacity(0.25))
		}
		.frame(maxWidth: .infinity).padding(.vertical, 48)
	}

	// MARK: - Add Button

	private var addButton: some View {
		Button { showAddHabit = true } label: {
			HStack(spacing: 8) {
				Image(systemName: "plus.circle.fill").font(.title3)
				Text("Добавить привычку").font(.body.weight(.semibold))
			}
			.foregroundStyle(accentColor)
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.background(accentColor.opacity(0.1))
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.overlay(RoundedRectangle(cornerRadius: 16).stroke(accentColor.opacity(0.3), lineWidth: 1))
		}
		.buttonStyle(SnapPressStyle())
	}

	// MARK: - Switch Mode Button

	private var switchModeButton: some View {
		Button {
			withAnimation(.spring(duration: 0.3)) {
				showBadHabits.toggle()
				calendarMonth = Date()
			}
		} label: {
			HStack(spacing: 8) {
				Image(systemName: showBadHabits ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
					.font(.title3)
				Text(showBadHabits ? "Обратно к привычкам" : "Вредные привычки")
					.font(.body.weight(.semibold))
			}
			.foregroundStyle(showBadHabits ? Color(hex: "4ADE80") : Color(hex: "F87171"))
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.background((showBadHabits ? Color(hex: "4ADE80") : Color(hex: "F87171")).opacity(0.08))
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke((showBadHabits ? Color(hex: "4ADE80") : Color(hex: "F87171")).opacity(0.25), lineWidth: 1)
			)
		}
		.buttonStyle(SnapPressStyle())
	}

	// MARK: - Helpers

	private var todayRate: Double {
		guard !currentHabits.isEmpty else { return 0 }
		return Double(currentHabits.filter { $0.isCompleted(on: .now) }.count) / Double(currentHabits.count)
	}
}
