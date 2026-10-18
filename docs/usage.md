# Використання проєкту

## Запуск агента у VS Code

1. Відкрийте репозиторій у **VS Code**.
2. Відкрийте панель **Copilot Chat**.
3. Оберіть custom agent **build-engineer**.
4. Запустіть команду `/init`.

Команда `/init` послідовно виконує генерацію структури проєкту, підготовку
залежностей і тестів, створення локальних CI-скриптів, налаштування GitHub
Actions та фінальну перевірку.

Після завершення повного сценарію запустіть read-only аудит:

```text
/check
```

Аудит має завершитися статусом `PASSED`.

## Локальна збірка і перевірка

### Linux/macOS

Запустіть локальний CI-скрипт:

```bash
./ci.sh
```

Скрипт створює `.venv` за потреби, встановлює залежності, запускає pytest і
копіює `src/hello.py` та `src/add.py` до `dist/`.

### Windows

Запустіть локальний CI-скрипт:

```bat
ci.bat
```

## Запуск Hello World

### Linux/macOS

Запуск зібраної копії:

```bash
python3 dist/hello.py
```

Очікуваний вивід:

```text
Hello, World!
```

Альтернативний запуск через скрипт:

```bash
./run.sh
```

### Windows

Запуск зібраної копії:

```bat
python dist\hello.py
```

Очікуваний вивід:

```text
Hello, World!
```

Альтернативний запуск через batch-скрипт:

```bat
run.bat
```

## Запуск тестів

### Linux/macOS

```bash
.venv/bin/python -m pytest -v
```

### Windows

```bat
.venv\Scripts\python -m pytest -v
```

Для запуску окремого тесту `test_basic_addition`:

```bash
.venv/bin/python -m pytest -v tests/test_basic.py::test_basic_addition
```

```bat
.venv\Scripts\python -m pytest -v tests\test_basic.py::test_basic_addition
```
