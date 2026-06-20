import SwiftUI

struct HabitRowView: View {
	var habit: Habit
	var isPressed: Bool = false

	private var isCompleted: Bool { habit.isCompleted(on: .now) }
	private var accent: Color { Color(hex: habit.colorHex) }

	var body: some View {
		HStack(spacing: 14) {
			iconCircle
			habitInfo
			Spacer()
			checkButton
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 14)
		.background(rowBackground)
		.scaleEffect(isPressed ? 0.95 : 1.0)
		.brightness(isPressed ? -0.06 : 0)
		// Быстрая пружина — ощущается мгновенно, но с живой анимацией
		.animation(.spring(response: 0.2, dampingFraction: 0.65), value: isPressed)
		.animation(.spring(duration: 0.25), value: isCompleted)
	}

	private var iconCircle: some View {
		ZStack {
			Circle()
				.fill(accent.opacity(isCompleted ? 0.25 : 0.15))
				.frame(width: 48, height: 48)
			Image(systemName: habit.iconName)
				.font(.title3)
				.foregroundStyle(accent.opacity(isCompleted ? 0.6 : 1.0))
		}
	}

	private var habitInfo: some View {
		VStack(alignment: .leading, spacing: 3) {
			Text(habit.name)
				.font(.body.weight(.semibold))
				.foregroundStyle(isCompleted ? .white.opacity(0.4) : .white)
				.strikethrough(isCompleted, color: .white.opacity(0.25))

			HStack(spacing: 4) {
				Text(frequencyIcon).font(.caption2)
				Text(habit.frequency.rawValue)
					.font(.caption2).foregroundStyle(.white.opacity(0.3))
			}

			if habit.currentStreak > 1 {
				HStack(spacing: 4) {
					Image(systemName: "flame.fill").font(.caption2).foregroundStyle(.orange)
					Text("\(habit.currentStreak) days in a row")
						.font(.caption2).foregroundStyle(.orange.opacity(0.85))
				}
				.transition(.opacity.combined(with: .scale(scale: 0.8)))
			}
		}
	}

	private var frequencyIcon: String {
		switch habit.frequency {
		case .daily:    return "🔄"
		case .weekdays: return "📅"
		case .weekends: return "🎉"
		}
	}

	private var checkButton: some View {
		Button {
			UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			withAnimation(.spring(duration: 0.3)) {
				habit.toggleCompletion(on: .now)
			}
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 13)
					.fill(isCompleted ? accent : Color.white.opacity(0.08))
					.frame(width: 46, height: 46)
				if isCompleted {
					Image(systemName: "checkmark")
						.font(.body.weight(.bold))
						.foregroundStyle(.white)
						.transition(.scale.combined(with: .opacity))
				}
			}
		}
		.buttonStyle(.plain)
	}

	private var rowBackground: some View {
		RoundedRectangle(cornerRadius: 18)
			.fill(Color.white.opacity(0.06))
			.overlay(
				RoundedRectangle(cornerRadius: 18)
					.stroke(isCompleted ? accent.opacity(0.45) : Color.clear, lineWidth: 1)
			)
	}
}
