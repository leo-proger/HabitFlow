# HabitFlow

**English** · [Русский](#русский)

iOS app for tracking habits, built with SwiftUI and SwiftData. HabitFlow helps you build
good habits and break bad ones: create habits with custom icons and colors, mark them as done,
get reminders, and follow your progress through statistics and a calendar.

Built as part of a team university project. This branch is my own part of the work — a complete
app from the data model to the UI.

## Features

- 📝 Create habits with a custom icon, color and frequency
- ✅ Mark completion and track streaks
- 👍 Support for both good and bad habits
- 🔔 Local reminder notifications
- 📊 Statistics screen with progress charts and analytics
- 📅 Monthly and full-screen calendar with completion visualization
- 🎨 Animated transitions and a side navigation menu

## Screenshots

<!-- Replace the placeholders with real screenshots -->

| Habit list | Statistics | Calendar |
|:---:|:---:|:---:|
| _screenshot_ | _screenshot_ | _screenshot_ |

| New habit | Habit details | Reminders |
|:---:|:---:|:---:|
| _screenshot_ | _screenshot_ | _screenshot_ |

## Tech stack

- **Swift** + **SwiftUI** — UI
- **SwiftData** — local persistence
- **UserNotifications** — reminders
- Architecture: split into models, views, managers and extensions

## Project structure

```
habit-tracker-trpo/
├── HabitFlowApp.swift        # entry point, SwiftData & notifications setup
├── SampleData.swift          # demo data seeding (for screenshots)
├── Models/
│   └── Habit.swift           # habit model: frequency, streaks, completion
├── Views/                    # screens and UI components
│   ├── ContentView.swift     # root tab navigation
│   ├── HabitListView.swift   # habit list
│   ├── AddHabitView.swift    # create a habit
│   ├── HabitDetailView.swift # details and editing
│   ├── StatisticsView.swift  # statistics and charts
│   ├── CalendarFullView.swift / MonthlyCalendarView.swift  # calendar
│   └── SideMenuView.swift    # side menu
├── Managers/
│   └── NotificationManager.swift  # local notifications
└── Extensions/
    └── ColorHex.swift        # working with HEX colors
```

## Getting started

1. Open `habit-tracker-trpo.xcodeproj` in Xcode.
2. Pick a simulator or an iOS device.
3. Run the project (`⌘R`).

> On first launch the app seeds demo habits (only into an empty database) so the screens look
> populated for screenshots. To disable, remove the `SampleData.seedIfNeeded(...)` call in
> `HabitFlowApp.swift`.

---

## Русский

[English](#habitflow) · **Русский**

**HabitFlow** — iOS-приложение для отслеживания привычек, написанное на SwiftUI и SwiftData.
Помогает формировать полезные привычки и избавляться от вредных: создавать привычки с
настраиваемыми иконками и цветами, отмечать выполнение, получать напоминания и следить за
прогрессом в статистике и календаре.

Проект сделан в рамках командной учебной разработки. Эта ветка — моя часть работы:
полнофункциональное приложение от модели данных до интерфейса.

### Возможности

- 📝 Создание привычек с выбором иконки, цвета и частоты выполнения
- ✅ Отметка выполнения и подсчёт серий (streak)
- 👍 Поддержка как полезных, так и вредных привычек
- 🔔 Локальные уведомления-напоминания
- 📊 Экран статистики с графиками прогресса и аналитикой
- 📅 Месячный и полноэкранный календарь с визуализацией выполнения
- 🎨 Анимированные переходы и боковое меню навигации

### Скриншоты

<!-- Замените плейсхолдеры на реальные скриншоты -->

| Список привычек | Статистика | Календарь |
|:---:|:---:|:---:|
| _скриншот_ | _скриншот_ | _скриншот_ |

| Создание привычки | Детали привычки | Уведомления |
|:---:|:---:|:---:|
| _скриншот_ | _скриншот_ | _скриншот_ |

### Технологии

- **Swift** + **SwiftUI** — интерфейс
- **SwiftData** — локальное хранение данных
- **UserNotifications** — напоминания
- Архитектура: разделение на модели, представления, менеджеры и расширения

### Структура проекта

```
habit-tracker-trpo/
├── HabitFlowApp.swift        # точка входа, настройка SwiftData и уведомлений
├── SampleData.swift          # засев демо-данных (для скриншотов)
├── Models/
│   └── Habit.swift           # модель привычки: частота, серии, выполнение
├── Views/                    # экраны и компоненты интерфейса
│   ├── ContentView.swift     # корневая навигация по вкладкам
│   ├── HabitListView.swift   # список привычек
│   ├── AddHabitView.swift    # создание привычки
│   ├── HabitDetailView.swift # детали и редактирование
│   ├── StatisticsView.swift  # статистика и графики
│   ├── CalendarFullView.swift / MonthlyCalendarView.swift  # календарь
│   └── SideMenuView.swift    # боковое меню
├── Managers/
│   └── NotificationManager.swift  # локальные уведомления
└── Extensions/
    └── ColorHex.swift        # работа с HEX-цветами
```

### Запуск

1. Откройте `habit-tracker-trpo.xcodeproj` в Xcode.
2. Выберите симулятор или устройство с iOS.
3. Запустите проект (`⌘R`).

> При первом запуске приложение засевает демо-привычки (только в пустую базу), чтобы экраны
> выглядели наполненными для скриншотов. Чтобы отключить — убери вызов
> `SampleData.seedIfNeeded(...)` в `HabitFlowApp.swift`.
