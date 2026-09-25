# Hacker Simulator: Zero Day — Blind Accessible

Аудио-хакер-симулятор, полностью управляемый клавиатурой и озвучиваемый через речевой синтезатор. Игра создана для незрячих и слабовидящих игроков.

## Описание

Вы — хакер-фрилансер. Ваша задача — взламывать серверы, людей и системы, используя звуковые подсказки и озвученные команды.

### Режимы игры

- **Сюжет** — 10 миссий с нарастающей сложностью и историей
- **Песочница** — свободная игра с настройкой числа целей и сложности
- **Лаборатория** — тренировка навыков взлома

### Управление

| Клавиша | Действие |
|---------|----------|
| S | Сканировать цели |
| C | Подключиться к серверу |
| E | Перечислить порты/инфо |
| F | Обойти защиту (фаервол) |
| B | Подбор доступа (bruteforce) |
| K | Взлом шифрования |
| D | Скачать данные |
| M | Спам/атака |
| X | Отключиться |
| H | Помощь |
| Стрелки ↑↓ | Навигация |
| Tab | Переключение между терминалом и результатами |
| Escape | Меню/отключение |
| Application (Menu) | Контекстное меню |
| ← → | История речи (назад/вперёд) |

### Цепочка взлома

```
F (защита) → B (доступ) → K (шифрование) → D (скачать)
```

## Требования

- [NVGT (Noliktor Game Toolkit)](https://nvgt.org) — движок для AngelScript (0.88+)
- Звуковые файлы в папке `sounds/`
- Для запуска достаточно открыть `main.nvgt` в NVGT (двойным кликом или `nvgt main.nvgt`). Никаких файлов рядом не требуется — игра работает «из коробки».

## Установка — Windows

1. Скачайте и установите NVGT
2. Скопируйте проект
3. Откройте `main.nvgt` в NVGT IDE
4. Нажмите Build & Run

## Установка — Linux

### Ubuntu / Debian

```bash
# Установите зависимости
sudo apt update
sudo apt install -y libopenal-dev libsdl2-dev

# Скачайте NVGT
git clone https://github.com/noliktor/nvgt.git
cd nvgt
make
sudo make install

# Запустите игру
cd /путь/к/hacker_game
nvgt main.nvgt
```

### Arch Linux

```bash
# Установите зависимости
sudo pacman -S openal sdl2

# Скачайте и соберите NVGT
git clone https://github.com/noliktor/nvgt.git
cd nvgt
make
sudo make install

# Запустите игру
cd /путь/к/hacker_game
nvgt main.nvgt
```

### Fedora / RHEL

```bash
# Установите зависимости
sudo dnf install -y openal-devel SDL2-devel

# Скачайте и соберите NVGT
git clone https://github.com/noliktor/nvgt.git
cd nvgt
make
sudo make install

# Запустите игру
cd /путь/к/hacker_game
nvgt main.nvgt
```

### Если NVGT недоступен

Игру можно запустить через [AngelScript](https://www.angelcode.com/angelscript/) с минимальными доработками — все скрипты написаны на чистом AngelScript без платформозависимого кода.

## Лицензия

Звуковые файлы: [Kenney](https://kenney.nl) (CC0 1.0 Universal)
