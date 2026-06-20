//
//  SideBarMenuView.swift
//  habit-flow
//
//  Created by Leo Proger on 3/17/2026.
//

import SwiftUI

struct SideMenuView: View {
	// @Binding — ссылка на @State родителя.
	// Изменение $selectedTab здесь изменяет selectedTab в ContentView.
	// Аналог передачи объекта по ссылке — но для примитивов и структур.
	@Binding var selectedTab: ContentView.AppTab
	@Binding var isMenuOpen: Bool

	// (String, String, ContentView.AppTab) — tuple, анонимная структура с тремя полями
	private let menuItems:
		[(icon: String, title: String, tab: ContentView.AppTab)] = [
			("checklist", "Habits", .habits),
			("chart.bar.fill", "Statistics", .statistics),
			("calendar", "Calendar", .calendar),
		]

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Шапка
			VStack(alignment: .leading, spacing: 6) {
				Image(systemName: "flame.fill")
					.font(.system(size: 36))
					.foregroundStyle(Color(hex: "4ADE80"))
					.padding(.bottom, 4)

				Text("HabitFlow")
					.font(.title.bold())
					.foregroundStyle(.white)

				Text("Build yourself every day")
					.font(.caption)
					.foregroundStyle(.white.opacity(0.35))
			}
			.padding(.horizontal, 24)
			.padding(.top, 64)
			.padding(.bottom, 28)

			Rectangle()
				.fill(Color.white.opacity(0.08))
				.frame(height: 1)
				.padding(.horizontal, 24)

			// Пункты меню
			VStack(spacing: 2) {
				ForEach(menuItems, id: \.tab) { item in
					menuButton(
						icon: item.icon,
						title: item.title,
						tab: item.tab
					)
				}
			}
			.padding(.top, 10)

			Spacer()
		}
		.frame(width: UIScreen.main.bounds.width * 0.72)
		.background(Color(hex: "0D1220"))
		.ignoresSafeArea()
	}

	private func menuButton(
		icon: String,
		title: String,
		tab: ContentView.AppTab
	) -> some View {
		let isSelected = selectedTab == tab

		// Button с двумя trailing closures: action и label
		return Button {
			withAnimation(.spring(duration: 0.25)) {
				selectedTab = tab
				isMenuOpen = false
			}
		} label: {
			HStack(spacing: 14) {
				ZStack {
					RoundedRectangle(cornerRadius: 9)
						.fill(
							isSelected
								? Color(hex: "4ADE80").opacity(0.2)
								: Color.white.opacity(0.06)
						)
						.frame(width: 36, height: 36)
					Image(systemName: icon)
						.font(.body)
						.foregroundStyle(
							isSelected
								? Color(hex: "4ADE80") : .white.opacity(0.45)
						)
				}

				Text(title)
					.font(.body.weight(isSelected ? .semibold : .regular))
					.foregroundStyle(isSelected ? .white : .white.opacity(0.55))

				Spacer()

				if isSelected {
					Circle()
						.fill(Color(hex: "4ADE80"))
						.frame(width: 6, height: 6)
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 14)
					.fill(
						isSelected
							? Color(hex: "4ADE80").opacity(0.08) : Color.clear
					)
			)
			.padding(.horizontal, 12)
		}
		.buttonStyle(.plain)  // убирает стандартное выделение кнопки
	}
}
