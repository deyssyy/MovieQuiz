# MovieQuiz 🎬

Одностраничное iOS-приложение — интерактивный квиз по фильмам из топ-250 рейтинга IMDb.

---

### ✨ Фичи и возможности
- 🌐 **Сетевой слой:** Асинхронная загрузка постеров и данных о фильмах из API IMDb.
- 📊 **Статистика:** Сохранение рекордов, даты лучшей игры и расчет средней точности.
- 🎨 **Интерактивный UI:** Адаптивная верстка, анимация и индикация ответов (зеленая/красная рамка).
- 🛡️ **Обработка ошибок:** Splash Screen при запуске и алерты при сбое сети с кнопкой повтора.

---

### 🛠️ Стек технологий и Архитектура

- **Архитектура:** `MVP` (полное разделение логики и вью через презентер).
- **Паттерны:** `QuestionFactory` (фабрика вопросов), `POP` (делегаты и протоколы).
- **UI:** `Swift` • `UIKit` • `Storyboard` • `Auto Layout` (iOS 15.0+, только портретный режим).
- **Сеть и данные:** `URLSession` • `REST API` • `Codable` • `UserDefaults` (статистика).
- **Тестирование:** `XCTest` (покрыто Unit-тестами презентера и UI-тестами экранов).

---

### 🚀 Запуск проекта

```bash
git clone https://github.com/deyssyy/MovieQuiz
open MovieQuiz.xcodeproj
```
Для корректной работы приложения нужно получить API Key на сайте https://imdb-api.com/.  Далее ключ нужно указать в url в коде [MoviesLoader.swift](https://github.com/deyssyy/MovieQuiz/blob/main/MovieQuiz/Services/MoviesLoader.swift)

---

### 🔗 Ссылки
[Макет Figma](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243) • [API IMDb](https://imdb-api.com/api#Top250Movies-header) • [Шрифты](https://code.s3.yandex.net/Mobile/iOS/Fonts/MovieQuizFonts.zip)
