# HabitFlow

![Swift](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17%2B-000000?logo=apple&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-15%2B-147EFB?logo=xcode&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

**English** · [Русский](#русский)

iOS app for tracking habits, built with SwiftUI and SwiftData. HabitFlow helps you build
good habits and break bad ones: create habits with custom icons and colors, mark them as done,
get reminders, and follow your progress through statistics and a calendar.

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

## Requirements

| Tool | Minimum version |
|---|---|
| Xcode | 15.0 |
| iOS (target) | 17.0 |
| macOS (host) | 13.5 Ventura |
| Swift | 5.9 |

> **No external dependencies.** The project uses only Apple's built-in frameworks —
> no Swift Package Manager packages, no CocoaPods, no Carthage.

## Getting Started

**1. Clone the repository**

```bash
git clone https://github.com/leo-proger/habit-flow.git
cd habit-flow
```

**2. Open in Xcode**

Double-click `habit-flow.xcodeproj`, or run:

```bash
open habit-flow.xcodeproj
```

Because there are no third-party packages, Xcode won't need to resolve any dependencies.

**3. Choose a run destination**

In the Xcode toolbar, pick any simulator running **iOS 17 or later** (e.g. iPhone 15).
To run on a physical device:

- Plug in your iPhone.
- Open **Signing & Capabilities** in the project settings.
- Select your Apple ID (a free account is sufficient for personal use).

**4. Build and run**

Press **⌘R** (or **Product → Run**).

> **Demo data:** on the very first launch the app seeds a small set of demo habits so every
> screen looks populated. This only happens once into an empty database and never overwrites
> real data. To disable it, remove the `SampleData.seedIfNeeded(...)` call in
> `HabitFlowApp.swift`.

## Tech stack

- **Swift** + **SwiftUI** — UI
- **SwiftData** — local persistence
- **UserNotifications** — reminders
- Architecture: split into models, views, managers and extensions

## Project structure

```
habit-flow/
├── HabitFlowApp.swift        # entry point, SwiftData & notifications setup
├── SampleData.swift          # demo data seeding (for screenshots)
├── Models/
│   └── Habit.swift           # habit model: frequency, streaks, completion
├── Views/                    # screens and UI components
│   ├── ContentView.swift     # root navigation with slide-out menu
│   ├── HabitListView.swift   # habit list
│   ├── HabitRowView.swift    # single habit row
│   ├── AddHabitView.swift    # create a habit
│   ├── HabitDetailView.swift # details and editing
│   ├── StatisticsView.swift  # statistics and charts
│   ├── CalendarFullView.swift     # full-screen calendar
│   ├── MonthlyCalendarView.swift  # compact monthly calendar widget
│   └── SideMenuView.swift    # slide-out side menu
├── Managers/
│   └── NotificationManager.swift  # local notifications
└── Extensions/
    └── ColorHex.swift        # Color(hex:) initializer
```

---

## Русский

[English](#habitflow) · **Русский**

**HabitFlow** — iOS-приложение для отслеживания привычек, написанное на SwiftUI и SwiftData.
Помогает формировать полезные привычки и избавляться от вредных: создавать привычки с
настраиваемыми иконками и цветами, отмечать выполнение, получать напоминания и следить за
прогрессом в статистике и календаре.

## Возможности

- 📝 Создание привычек с выбором иконки, цвета и частоты выполнения
- ✅ Отметка выполнения и подсчёт серий (streak)
- 👍 Поддержка как полезных, так и вредных привычек
- 🔔 Локальные уведомления-напоминания
- 📊 Экран статистики с графиками прогресса и аналитикой
- 📅 Месячный и полноэкранный календарь с визуализацией выполнения
- 🎨 Анимированные переходы и боковое меню навигации

## Скриншоты

<!-- Замените плейсхолдеры на реальные скриншоты -->

| Список привычек | Статистика | Календарь |
|:---:|:---:|:---:|
| _скриншот_ | _скриншот_ | _скриншот_ |

| Создание привычки | Детали привычки | Уведомления |
|:---:|:---:|:---:|
| _скриншот_ | _скриншот_ | _скриншот_ |

## Требования

| Инструмент | Минимальная версия |
|---|---|
| Xcode | 15.0 |
| iOS (целевая платформа) | 17.0 |
| macOS (хост-машина) | 13.5 Ventura |
| Swift | 5.9 |

> **Внешних зависимостей нет.** Проект использует только встроенные фреймворки Apple —
> никаких пакетов Swift Package Manager, CocoaPods или Carthage.

## Запуск

**1. Клонируйте репозиторий**

```bash
git clone https://github.com/leo-proger/habit-flow.git
cd habit-flow
```

**2. Откройте проект в Xcode**

Дважды кликните по `habit-flow.xcodeproj` или выполните:

```bash
open habit-flow.xcodeproj
```

Так как внешних зависимостей нет, Xcode не будет ничего загружать и разрешать.

**3. Выберите устройство для запуска**

В тулбаре Xcode выберите любой симулятор с **iOS 17 или новее** (например, iPhone 15).
Чтобы запустить на реальном устройстве:

- Подключите iPhone по кабелю.
- Откройте вкладку **Signing & Capabilities** в настройках проекта.
- Выберите свой Apple ID (для личного использования достаточно бесплатного аккаунта).

**4. Сборка и запуск**

Нажмите **⌘R** (или **Product → Run**).

> **Демо-данные:** при первом запуске приложение засевает набор демо-привычек, чтобы все
> экраны выглядели наполненными. Это происходит только один раз в пустую базу и никогда не
> перезаписывает реальные данные. Чтобы отключить — удалите вызов
> `SampleData.seedIfNeeded(...)` в `HabitFlowApp.swift`.

## Технологии

- **Swift** + **SwiftUI** — интерфейс
- **SwiftData** — локальное хранение данных
- **UserNotifications** — напоминания
- Архитектура: разделение на модели, представления, менеджеры и расширения

## Структура проекта

```
habit-flow/
├── HabitFlowApp.swift        # точка входа, настройка SwiftData и уведомлений
├── SampleData.swift          # засев демо-данных (для скриншотов)
├── Models/
│   └── Habit.swift           # модель привычки: частота, серии, выполнение
├── Views/                    # экраны и компоненты интерфейса
│   ├── ContentView.swift     # корневая навигация с боковым меню
│   ├── HabitListView.swift   # список привычек
│   ├── HabitRowView.swift    # строка отдельной привычки
│   ├── AddHabitView.swift    # создание привычки
│   ├── HabitDetailView.swift # детали и редактирование
│   ├── StatisticsView.swift  # статистика и графики
│   ├── CalendarFullView.swift     # полноэкранный календарь
│   ├── MonthlyCalendarView.swift  # компактный виджет месячного календаря
│   └── SideMenuView.swift    # боковое меню
├── Managers/
│   └── NotificationManager.swift  # локальные уведомления
└── Extensions/
    └── ColorHex.swift        # инициализатор Color(hex:)
```
