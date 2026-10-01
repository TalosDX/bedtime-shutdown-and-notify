# Bedtime Shutdown

**[Русский](#русский) | [English](#english)**

---

## Русский

Мягкое ночное автовыключение ПК для Windows 10/11. Помогает вовремя лечь спать, если засиживаешься за компьютером или играми.

Обычная задача `shutdown /s /t 0` в Планировщике выключает компьютер внезапно, и её быстро хочется отключить. Этот скрипт сначала **15 минут предупреждает**, и только потом выключает ПК.

### Как это работает

| Когда | Что происходит |
|---|---|
| за 15 мин | баннер «Выключение через 15 минут» + тихий звук |
| за 10 мин | баннер + **экран становится чёрно-белым** |
| за 5 мин | баннер + тихий звук |
| последняя минута | баннер с отсчётом секунд + бип раз в секунду, громкость плавно растёт |
| 0 | `shutdown /s /t 0` |

- **Баннер — своё окно, а не уведомление Windows.** Фокусировка внимания («Не беспокоить») его не скрывает. Окно всегда поверх остальных и не забирает фокус, поэтому игру не свернёт.
- **Чёрно-белый режим** включается через Windows Magnification API и держится, только пока работает скрипт. После перезагрузки цвета вернутся сами.
- **Звук не оглушает.** Отсчёт начинается с 10% и доходит максимум до 50% (относительно системной громкости).
- **Без окон консоли.** Скрипт запускается через `run-hidden.vbs`, так что консоль не мелькает и не выкидывает из полноэкранной игры.

### Установка

1. Скачай репозиторий в постоянную папку, например `C:\Users\<ты>\Scripts\Bedtime`.
2. Запусти:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install-task.ps1
   ```
   Скрипт создаст (или перезапишет) задачу **«Автовыключение Компа»**. Она запускается каждый день в 21:45, 22:45 … 6:45, так что ПК выключается ровно в 22:00, 23:00 … 7:00. Если включить компьютер посреди ночи, он выключится в ближайший час.

Если появится ошибка «Отказано в доступе», запусти PowerShell от имени администратора.

### Проверка

Тестовый прогон: паузы по 5 секунд, отсчёт идёт полную минуту, **ПК не выключается**:

```powershell
wscript.exe .\run-hidden.vbs bedtime-shutdown.ps1 -Test
```

Чтобы проверить в игре, добавь задержку и за это время переключись в игру:

```powershell
Start-Sleep 60; wscript.exe .\run-hidden.vbs bedtime-shutdown.ps1 -Test
```

### Настройка

- **Громкость:** переменные в начале `bedtime-shutdown.ps1`: `$WarnVolume`, `$MinVolume`, `$MaxVolume` (0.0–1.0).
- **Расписание:** часы перечислены в `install-task.ps1`: `(21..23) + (0..6)`. После изменения запусти его ещё раз.

### Ограничения

- В играх с режимом «Полный экран» (exclusive fullscreen) баннер может быть не виден. Звук и ч/б будут работать в любом случае. Режим «Оконный без рамки» (borderless) работает лучше.
- Выключение идёт без `/f`. Если приложение мешает завершению работы, Windows покажет экран, где его можно отменить. Для принудительного выключения замени на `shutdown /s /f /t 0`.
- Кнопки «отложить» нет специально.

### Файлы

| Файл | Назначение |
|---|---|
| `bedtime-shutdown.ps1` | основной скрипт: предупреждения, ч/б, отсчёт, выключение |
| `run-hidden.vbs` | запускает `.ps1` без окна консоли |
| `install-task.ps1` | создаёт задачу в Планировщике |
| `tick.wav` | мягкий бип для отсчёта (880 Гц, 120 мс) |

---

## English

A gentle nightly auto-shutdown for Windows 10/11. It helps you get to bed on time if you tend to stay up late at the computer or gaming.

A plain `shutdown /s /t 0` scheduled task turns the PC off without warning, so you quickly end up disabling it. This script **warns you for 15 minutes first**, then shuts the PC down.

### How it works

| When | What happens |
|---|---|
| 15 min before | banner "shutdown in 15 minutes" + soft sound |
| 10 min before | banner + **screen turns grayscale** |
| 5 min before | banner + soft sound |
| last minute | banner with a seconds countdown + a beep every second, volume ramps up |
| 0 | `shutdown /s /t 0` |

- **The banner is its own window, not a Windows notification.** Focus Assist ("Do not disturb") can't hide it. It stays on top of everything and never takes focus, so it won't minimize your game.
- **Grayscale** uses the Windows Magnification API and only lasts while the script is running. After a reboot, colors come back on their own.
- **The sound won't blast you.** The countdown starts at 10% and goes up to 50% at most (relative to system volume).
- **No console windows.** The script runs through `run-hidden.vbs`, so no console flashes up and kicks you out of a fullscreen game.

Banner text is in Russian. Change the `Show-Warning` strings in `bedtime-shutdown.ps1` to translate it.

### Install

1. Download the repo to a permanent folder, e.g. `C:\Users\<you>\Scripts\Bedtime`.
2. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install-task.ps1
   ```
   This creates (or overwrites) the scheduled task **"Автовыключение Компа"**. It runs daily at 21:45, 22:45 … 6:45, so the PC shuts down exactly at 22:00, 23:00 … 7:00. If you turn the computer on in the middle of the night, it shuts down at the next full hour.

If you get "Access denied", run PowerShell as administrator.

### Testing

Test run with 5-second pauses and the full one-minute countdown. **The PC does not shut down:**

```powershell
wscript.exe .\run-hidden.vbs bedtime-shutdown.ps1 -Test
```

To test inside a game, add a delay and switch to the game in the meantime:

```powershell
Start-Sleep 60; wscript.exe .\run-hidden.vbs bedtime-shutdown.ps1 -Test
```

### Configuration

- **Volume:** variables at the top of `bedtime-shutdown.ps1`: `$WarnVolume`, `$MinVolume`, `$MaxVolume` (0.0–1.0).
- **Schedule:** the hours are listed in `install-task.ps1`: `(21..23) + (0..6)`. Run it again after editing.

### Limitations

- In exclusive-fullscreen games the banner may not be visible. Sound and grayscale still work. Borderless windowed mode works better.
- Shutdown runs without `/f`. If an app blocks shutdown, Windows shows a screen where you can cancel it. For a forced shutdown, use `shutdown /s /f /t 0`.
- There is no snooze button, on purpose.

### Files

| File | Purpose |
|---|---|
| `bedtime-shutdown.ps1` | main script: warnings, grayscale, countdown, shutdown |
| `run-hidden.vbs` | runs a `.ps1` with no console window |
| `install-task.ps1` | registers the scheduled task |
| `tick.wav` | soft countdown beep (880 Hz, 120 ms) |

---

MIT License — see [LICENSE](LICENSE).
