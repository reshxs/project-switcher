# Project Switcher

Консольная утилита для быстрого переключения между проектами в терминале.

## Возможности

- Быстрое переключение между проектами с командой `project open`
- Создание новых проектов с инициализацией git через `project new`
- Открытие проектов в IDE (PyCharm, VS Code, Claude)
- Автодополнение названий проектов (Tab completion)
- Настраиваемая директория проектов
- Модульная архитектура с отдельными командами
- Простая сборка и установка
- Поддержка zsh

## Установка

```bash
cd project-switcher
chmod +x build.sh install.sh
./build.sh
./install.sh
```

После установки перезапустите терминал или выполните:

```bash
source ~/.zshrc
```

## Использование

### Основные команды

Открыть существующий проект:

```bash
project open <название-проекта>
```

Создать новый проект с инициализацией git:

```bash
project new <название-проекта>
```

Открыть проект в IDE:

```bash
project open -py <название-проекта>       # Открыть в PyCharm
project open -code <название-проекта>     # Открыть в VS Code
project open -claude <название-проекта>   # Открыть в Claude
project open -py -code <название-проекта> # Комбинация флагов
```

То же работает и для `project new`:

```bash
project new -code <название-проекта>      # Создать и открыть в VS Code
```

Список всех проектов:

```bash
project list
```

Справка:

```bash
project --help
# или
project -h
```

Автодополнение работает по нажатию Tab.

## Конфигурация

По умолчанию утилита ищет проекты в `~/Projects`.

Чтобы изменить директорию, отредактируйте файл `~/.config/project-switcher/config`:

```bash
# Ваша кастомная директория
PROJECTS_DIR="${HOME}/MyProjects"
```

## Обновление

Для обновления пересоберите и переустановите:

```bash
./build.sh
./install.sh
```

Ваши настройки сохранятся.

## Удаление

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Деинсталлятор предложит удалить конфигурацию (опционально).

## Структура проекта

### Исходные файлы

```
project-switcher/
├── project-switcher.sh      # Точка входа, роутинг команд
├── commands/
│   ├── open.sh              # Команда 'project open'
│   ├── new.sh               # Команда 'project new'
│   └── list.sh              # Команда 'project list'
├── lib/
│   └── helpers.sh           # Общие helper функции
├── build.sh                 # Скрипт сборки
├── install.sh               # Скрипт установки
└── uninstall.sh             # Скрипт удаления
```

### Установленные файлы

```
~/.local/bin/project-switcher       # Собранный исполняемый файл
~/.config/project-switcher/config   # Конфигурация
~/.zshrc                            # Автоматически добавляется source
```

## Требования

- zsh
- Директория с проектами (по умолчанию `~/Projects`)

## Лицензия

MIT
