//
//  AddHabitView.swift
//  habit-tracker-trpo
//
//  Created by Leo Proger on 3/17/2026.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
	var isBad: Bool = false

	@Environment(\.modelContext) private var modelContext
	// @Environment(\.dismiss) — получаем функцию закрытия sheet из окружения
	@Environment(\.dismiss) private var dismiss

	@State private var name = ""
	@State private var description = ""
	@State private var frequency: Habit.Frequency = .daily
	@State private var selectedColor = "4ADE80"
	@State private var selectedIcon = "star.fill"
	@State private var reminderOn = false
	@State private var reminderTime: Date = {
		// Closure для вычисления default value — задаём 08:00
		Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
	}()

	private let colors = ["4ADE80", "60A5FA", "A78BFA", "FB923C", "F472B6", "FBBF24", "34D399", "F87171"]
	private let icons  = ["star.fill", "heart.fill", "bolt.fill", "book.fill", "figure.walk",
						  "moon.fill", "drop.fill", "leaf.fill", "flame.fill", "music.note",
						  "bicycle", "dumbbell.fill", "cup.and.saucer.fill", "brain.head.profile"]

	var body: some View {
		NavigationStack {
			ZStack {
				Color(hex: "0A0E1A").ignoresSafeArea()
				ScrollView(showsIndicators: false) {
					VStack(spacing: 22) {
						textFields
						frequencySection
						colorSection
						iconSection
						reminderSection
					}
					.padding(20)
					.padding(.bottom, 20)
				}
			}
			.navigationTitle(isBad ? "Новая вредная привычка" : "Новая привычка")
			.navigationBarTitleDisplayMode(.inline)
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Отмена") { dismiss() }
						.foregroundStyle(.white.opacity(0.5))
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Создать") { save() }
						.foregroundStyle(name.isEmpty ? .white.opacity(0.2) : Color(hex: "4ADE80"))
						.fontWeight(.semibold)
						.disabled(name.isEmpty)
				}
			}
		}
	}

	// MARK: - Sections

	private var textFields: some View {
		VStack(spacing: 10) {
			TextField("Название", text: $name)  // $name — Binding<String>
				.styledField()
			TextField("Описание (необязательно)", text: $description)
				.styledField()
		}
	}

	private var frequencySection: some View {
		section(title: "Периодичность") {
			// Picker с .segmented стилем — горизонтальные кнопки
			Picker("", selection: $frequency) {
				ForEach(Habit.Frequency.allCases, id: \.self) { f in
					Text(f.rawValue).tag(f)
					// .tag — идентификатор для Picker, соответствует типу selection
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
							if selectedColor == hex {
								Circle().stroke(.white, lineWidth: 2.5)
								Image(systemName: "checkmark")
									.font(.caption2.bold())
									.foregroundStyle(.white)
							}
						}
						.onTapGesture { withAnimation { selectedColor = hex } }
				}
			}
		}
	}

	private var iconSection: some View {
		section(title: "Иконка") {
			// LazyVGrid — ленивая сетка, аналог RecyclerView с GridLayoutManager
			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
				ForEach(icons, id: \.self) { icon in
					ZStack {
						RoundedRectangle(cornerRadius: 10)
							.fill(selectedIcon == icon
								  ? Color(hex: selectedColor).opacity(0.25)
								  : Color.white.opacity(0.06))
							.frame(height: 46)
						Image(systemName: icon)
							.font(.body)
							.foregroundStyle(selectedIcon == icon
											 ? Color(hex: selectedColor)
											 : .white.opacity(0.4))
					}
					.onTapGesture { withAnimation { selectedIcon = icon } }
				}
			}
		}
	}

	private var reminderSection: some View {
		section(title: "Напоминание") {
			VStack(spacing: 12) {
				Toggle(isOn: $reminderOn) {
					Label("Включить", systemImage: "bell.fill")
						.foregroundStyle(.white)
				}
				.tint(Color(hex: selectedColor))

				if reminderOn {
					DatePicker("Время", selection: $reminderTime, displayedComponents: .hourAndMinute)
						.foregroundStyle(.white)
						.colorScheme(.dark)
						// transition — анимация появления DatePicker
						.transition(.opacity.combined(with: .move(edge: .top)))
				}
			}
			.animation(.spring(duration: 0.2), value: reminderOn)
		}
	}

	// Generic helper для секций с заголовком
	// @ViewBuilder content: () -> Content — принимает замыкание возвращающее View
	private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
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

	// MARK: - Actions

	private func save() {
		let habit = Habit(
			name: name,
			habitDescription: description,
			colorHex: selectedColor,
			iconName: selectedIcon,
			frequency: frequency,
			reminderTime: reminderOn ? reminderTime : nil,
			isBad: isBad
		)
		modelContext.insert(habit)
		NotificationManager.schedule(for: habit)
		dismiss()
	}
}

// MARK: - TextField Style Extension
// Расширяем View, добавляя модификатор .styledField()
private extension View {
	func styledField() -> some View {
		self
			.padding(.horizontal, 16)
			.padding(.vertical, 14)
			.background(Color.white.opacity(0.06))
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.foregroundStyle(.white)
			.font(.body)
	}
}
