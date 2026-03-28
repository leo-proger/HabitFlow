//
//  ContentView.swift
//  habit-tracker-trpo
//
//  Created by Leo Proger on 3/17/2026.
//

import SwiftUI

struct ContentView: View {
	// @State — локальное реактивное состояние View.
	// При изменении @State Swift перерисовывает body.
	// private — хорошая практика: состояние не должно быть доступно снаружи
	@State private var isMenuOpen = false
	@State private var selectedTab: AppTab = .habits

	// Enum внутри View — нормальная практика в Swift
	enum AppTab {
		case habits, statistics, calendar
	}

	var body: some View {
		// ZStack — слои поверх друг друга (как FrameLayout в Android)
		// alignment: .leading — все дочерние элементы прибиваем к левому краю
		ZStack(alignment: .leading) {

			// Основной контент
			mainContent
				.frame(maxWidth: .infinity, maxHeight: .infinity)

			// Затемняющий оверлей при открытом меню
			if isMenuOpen {
				Color.black.opacity(0.55)
					.ignoresSafeArea()
					.onTapGesture {
						withAnimation(.spring(duration: 0.3)) {
							isMenuOpen = false
						}
					}
					// zIndex гарантирует правильный порядок слоёв
					.zIndex(1)
			}

			// Боковое меню
			if isMenuOpen {
				SideMenuView(selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
				// .transition — анимация появления/исчезновения view
					.transition(.move(edge: .leading))
					.zIndex(2)
			}
		}
		// .animation — анимирует изменения при изменении isMenuOpen
		.animation(.spring(duration: 0.3), value: isMenuOpen)
	}

	// @ViewBuilder — позволяет использовать if/switch внутри computed property,
	// возвращающего View. Без него компилятор не поймёт if/switch.
	@ViewBuilder
	private var mainContent: some View {
		switch selectedTab {
		case .habits:
			HabitListView(isMenuOpen: $isMenuOpen)
		case .statistics:
			StatisticsView(isMenuOpen: $isMenuOpen)
		case .calendar:
			CalendarFullView(isMenuOpen: $isMenuOpen)
		}
	}

	private func placeholderView(title: String, icon: String) -> some View {
		ZStack {
			Color(hex: "0A0E1A").ignoresSafeArea()
			VStack(spacing: 12) {
				Image(systemName: icon)
					.font(.system(size: 48))
					.foregroundStyle(Color(hex: "4ADE80").opacity(0.4))
				Text(title)
					.font(.title2.bold())
					.foregroundStyle(.white.opacity(0.4))
				Text("В разработке")
					.font(.caption)
					.foregroundStyle(.white.opacity(0.2))
			}
		}
	}
}

#Preview {
    ContentView()
}
