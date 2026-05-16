# HeartTalk

## О приложении

HeartTalk помогает парам выйти за рамки привычных разговоров. Приложение предлагает ежедневные вопросы по важным темам в отношениях, позволяет отмечать обсуждённые вопросы, добавлять личные заметки и отслеживать прогресс общения.

Заметки к вопросам анализируются встроенной CoreML-моделью — приложение определяет тональность записи (позитивная / нейтральная / негативная) и отображает эмоциональный контекст.

---

## Возможности

- **Карточки вопросов** — тематические вопросы для пар, загружаются из `questions.json`
- **Избранное** — сохранение важных вопросов для повторного обсуждения
- **Заметки** — личные записи к каждому вопросу (до 100 символов)
- **Анализ тональности** — CoreML-модель определяет настроение заметки
- **Статистика** — прогресс обсуждённых тем, streak активности
- **Уведомления** — ежедневное напоминание с новым вопросом
- **Онбординг** — ввод имён партнёров при первом запуске

---

## Архитектура

Приложение построено на паттерне **MVVM** с чёткими слоями ответственности:

```
VIEW (UIKit ViewControllers)
  ↕ closures
VIEWMODEL (бизнес-логика)
  ↓
QuestionRepository (протокол → подменяется в тестах)
  ├── CoreData  (прогресс · избранное · заметки)
  └── questions.json  (контент вопросов, read-only)

NLPService (CoreML + NaturalLanguage)
```

**Ключевые решения:**
- `QuestionRepository` — протокол, что позволяет подменять реализацию в unit-тестах
- CoreData хранит только изменяемый прогресс пользователя; контент вопросов иммутабелен и живёт в Bundle
- Streak, настройки, daily-cache → UserDefaults
- Связь между сущностями CoreData — логический `questionID`, без CoreData relationships

---

## Стек технологий

| Категория | Технология |
|-----------|-----------|
| Язык | Swift 5.9 |
| UI | UIKit (программный layout, без Storyboard) |
| Архитектура | MVVM |
| Локальная БД | CoreData |
| ML | CoreML + NaturalLanguage (NLP.mlmodel) |
| Уведомления | UNUserNotificationCenter |
| CI/CD | GitHub Actions |
| Тесты | XCTest (Unit + UI) |

---

## Структура проекта

```
HeartTalk/
├── App/                    # AppDelegate, SceneDelegate
├── Models/
│   ├── CoreData/           # CoreDataStack + NSManagedObject entities
│   ├── Question.swift      # Codable struct (контент из JSON)
│   └── UserSettings.swift
├── Services/
│   ├── QuestionRepository.swift   # Протокол + реализация
│   ├── QuestionLoader.swift       # Загрузка questions.json
│   ├── NLPService.swift           # CoreML анализ тональности
│   └── NotificationService.swift
├── ViewModels/             # Бизнес-логика каждого экрана
├── Views/
│   ├── Main/               # Основные экраны
│   ├── Onboarding/         # Сплэш, онбординг
│   └── Components/         # Переиспользуемые UI-компоненты
└── Resources/
    ├── questions.json
    ├── NLP.mlmodel
    └── Assets.xcassets
```

---

## CoreData модель

Три независимые плоские сущности без relationships:

| Entity | Поля | Назначение |
|--------|------|-----------|
| `DiscussedEntry` | questionID, discussedAt | Факт «вопрос обсуждён» |
| `FavoriteEntry` | questionID, addedAt | Вопрос в избранном |
| `NoteEntry` | questionID, text, updatedAt | Личная заметка |

---

## CI/CD

GitHub Actions запускает три job-а на каждый `push` и `pull_request` в `main` / `develop`:

```
push / PR
   ├── Unit Tests (HeartTalkTests)   ┐ параллельно
   └── UI Tests (HeartTalkUITests)   ┘
              ↓ оба прошли
         Build Release Archive
         (только push в main)
```

- Симулятор выбирается динамически по UDID — не ломается при обновлении runner-а
- DerivedData кешируется между запусками
- Результаты тестов сохраняются как артефакты (14 дней)
- Release-архив сохраняется как артефакт (30 дней)

---

## Связанные репозитории

- [Анализ уведомлений](https://github.com/KirillKrainov22/notification_for_coursework) — исследование эффективности push-уведомлений
- [ML-модель (анализ тональности)](https://github.com/KirillKrainov22/ios-sentiment-analysis) — подробная информация об обучении и архитектуре NLP.mlmodel

---

## Запуск проекта

**Требования:**
- Xcode 15+
- iOS 16+
- macOS 13+

**Шаги:**
```bash
git clone git@github.com:KirillKrainov22/HeartTalk.git
cd HeartTalk
open HeartTalk.xcodeproj
```

Запустить на симуляторе: `Cmd + R`

**Тесты:**
```bash
# Unit-тесты
xcodebuild test -project HeartTalk.xcodeproj -scheme HeartTalk \
  -only-testing:HeartTalkTests -destination 'platform=iOS Simulator,name=iPhone 16'

# UI-тесты
xcodebuild test -project HeartTalk.xcodeproj -scheme HeartTalk \
  -only-testing:HeartTalkUITests -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Автор

**Кирилл Крайнов** — iOS-разработчик  
[github.com/KirillKrainov22](https://github.com/KirillKrainov22)

