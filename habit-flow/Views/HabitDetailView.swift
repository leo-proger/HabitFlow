//
//  HabitDetailView.swift
//  habit-flow
//
//  Created by Leo Proger on 3/28/2026.
//

import SwiftData
import SwiftUI

struct HabitDetailView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss

	var habit: Habit

	// Локальные копии для редактирования — меняем только при сохранении
	@State private var name: String
	@State private var description: String
	@State private var frequency: Habit.Frequency
	@State private var colorHex: String
	@State private var iconName: String
	@State private var reminderOn: Bool
	@State private var reminderTime: Date
	@State private var showDeleteAlert = false

	private let colors = [
		"4ADE80", "60A5FA", "A78BFA", "FB923C", "F472B6", "FBBF24", "34D399",
		"F87171",
	]
	private let icons = [
		"star.fill", "heart.fill", "bolt.fill", "book.fill", "figure.walk",
		"moon.fill", "drop.fill", "leaf.fill", "flame.fill", "music.note",
		"bicycle", "dumbbell.fill", "cup.and.saucer.fill", "brain.head.profile",
	]

	// init нужен чтобы заполнить @State из переданного habit
	init(habit: Habit) {
		self.habit = habit
		_name = State(initialValue: habit.name)
		_description = State(initialValue: habit.habitDescription)
		_frequency = State(initialValue: habit.frequency)
		_colorHex = State(initialValue: habit.colorHex)
		_iconName = State(initialValue: habit.iconName)
		_reminderOn = State(initialValue: habit.reminderTime != nil)
		_reminderTime = State(
			initialValue: habit.reminderTime
				?? Calendar.current.date(
					bySettingHour: 8,
					minute: 0,
					second: 0,
					of: Date()
				)
				?? Date()
		)
	}

	var body: some View {
		NavigationStack {
			ZStack {
				Color(hex: "0A0E1A").ignoresSafeArea()
				ScrollView(showsIndicators: false) {
					VStack(spacing: 22) {
						// Превью иконки
						iconPreview
						textFields
						frequencySection
						colorSection
						iconSection
						reminderSection
						deleteButton
					}
					.padding(20)
					.padding(.bottom, 20)
				}
			}
			.navigationTitle("Привычка")
			.navigationBarTitleDisplayMode(.inline)
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Отмена") { dismiss() }
						.foregroundStyle(.white.opacity(0.5))
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Сохранить") { save() }
						.foregroundStyle(
							name.isEmpty
								? .white.opacity(0.2) : Color(hex: colorHex)
						)
						.fontWeight(.semibold)
						.disabled(name.isEmpty)
				}
			}
		}
		.alert("Удалить привычку?", isPresented: $showDeleteAlert) {
			Button("Удалить", role: .destructive) {
				NotificationManager.cancel(for: habit.id)
				modelContext.delete(habit)
				dismiss()
			}
			Button("Отмена", role: .cancel) {}
		} message: {
			Text("Весь прогресс будет удалён безвозвратно.")
		}
	}

	// MARK: - Sections (такие же как в AddHabitView)

	private var iconPreview: some View {
		ZStack {
			Circle()
				.fill(Color(hex: colorHex).opacity(0.15))
				.frame(width: 80, height: 80)
			Image(systemName: iconName)
				.font(.system(size: 34))
				.foregroundStyle(Color(hex: colorHex))
		}
		.animation(.spring(duration: 0.2), value: colorHex)
		.animation(.spring(duration: 0.2), value: iconName)
	}

	private var textFields: some View {
		VStack(spacing: 10) {
			TextField("Название", text: $name)
				.styledField()
			TextField("Описание (необязательно)", text: $description)
				.styledField()
		}
	}

	private var frequencySection: some View {
		section(title: "Периодичность") {
			Picker("", selection: $frequency) {
				ForEach(Habit.Frequency.allCases, id: \.self) { f in
					Text(f.rawValue).tag(f)
				}
			}
			.pickerStyle(.segmented)
			.colorScheme(.dark)
		}
	}

	private var colorSection: some View {
		section(title: "Цвет") {
			HStack(spacing: 10) {
				ForEach(colors, id: \.self) { hex in
					Circle()
						.fill(Color(hex: hex))
						.frame(width: 34, height: 34)
						.overlay {
							if colorHex == hex {
								Circle().stroke(.white, lineWidth: 2.5)
								Image(systemName: "checkmark").font(
									.caption2.bold()
								).foregroundStyle(.white)
							}
						}
						.onTapGesture { withAnimation { colorHex = hex } }
				}
			}
		}
	}

	private var iconSection: some View {
		section(title: "Иконка") {
			LazyVGrid(
				columns: Array(repeating: GridItem(.flexible()), count: 7),
				spacing: 10
			) {
				ForEach(icons, id: \.self) { icon in
					ZStack {
						RoundedRectangle(cornerRadius: 10)
							.fill(
								iconName == icon
									? Color(hex: colorHex).opacity(0.25)
									: Color.white.opacity(0.06)
							)
							.frame(height: 46)
						Image(systemName: icon)
							.font(.body)
							.foregroundStyle(
								iconName == icon
									? Color(hex: colorHex) : .white.opacity(0.4)
							)
					}
					.onTapGesture { withAnimation { iconName = icon } }
				}
			}
		}
	}

	private var reminderSection: some View {
		section(title: "Напоминание") {
			VStack(spacing: 12) {
				Toggle(isOn: $reminderOn) {
					Label("Включить", systemImage: "bell.fill").foregroundStyle(
						.white
					)
				}
				.tint(Color(hex: colorHex))
				if reminderOn {
					DatePicker(
						"Время",
						selection: $reminderTime,
						displayedComponents: .hourAndMinute
					)
					.foregroundStyle(.white)
					.colorScheme(.dark)
					.transition(.opacity.combined(with: .move(edge: .top)))
				}
			}
			.animation(.spring(duration: 0.2), value: reminderOn)
		}
	}

	private var deleteButton: some View {
		Button {
			showDeleteAlert = true
		} label: {
			HStack(spacing: 8) {
				Image(systemName: "trash.fill")
				Text("Удалить привычку")
					.fontWeight(.semibold)
			}
			.foregroundStyle(Color(hex: "F87171"))
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.background(Color(hex: "F87171").opacity(0.08))
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke(Color(hex: "F87171").opacity(0.25), lineWidth: 1)
			)
		}
	}

	private func section<Content: View>(
		title: String,
		@ViewBuilder content: () -> Content
	) -> some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(title)
				.font(.caption.weight(.semibold))
				.foregroundStyle(.white.opacity(0.4))
				.textCase(.uppercase)
				.kerning(0.5)
			content()
		}
		.padding(14)
		.background(Color.white.opacity(0.05))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}

	// MARK: - Save

	private func save() {
		habit.name = name
		habit.habitDescription = description
		habit.frequency = frequency
		habit.colorHex = colorHex
		habit.iconName = iconName
		habit.reminderTime = reminderOn ? reminderTime : nil
		NotificationManager.schedule(for: habit)
		dismiss()
	}
}

extension View {
	fileprivate func styledField() -> some View {
		self
			.padding(.horizontal, 16)
			.padding(.vertical, 14)
			.background(Color.white.opacity(0.06))
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.foregroundStyle(.white)
			.font(.body)
	}
}

#Preview {
	HabitDetailView(habit: Habit(
		name: "Пробежка",
		habitDescription: "Утренняя пробежка 30 минут",
		colorHex: "4ADE80",
		iconName: "figure.walk",
		frequency: .daily,
		reminderTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())
	))
	.modelContainer(for: Habit.self, inMemory: true)
}


