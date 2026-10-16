---
name: build-and-test
description: "Use when building, testing, or preparing runnable scripts and cross-platform CI for a Python project that already contains src/hello.py and src/add.py."
argument-hint: "Run build-and-test for the existing Python source modules."
user-invocable: true
disable-model-invocation: false
---

# Build and Test

## Призначення

Цей skill готує залежності, конфігурацію `pytest`, локальні скрипти запуску
та кросплатформні CI-скрипти для Python-проєкту. Застосовуй його після
створення модулів `src/hello.py` і `src/add.py`, коли потрібно перевірити
додавання, запуск програми та підготувати теку `dist/`.

## Вхідні дані

Перед початком підтвердь, що існують і доступні для читання:

```text
src/hello.py
src/add.py
```

Якщо будь-який модуль відсутній, зупинись і повідом, що спочатку потрібно
виконати scaffolding. Не створюй замінники цих модулів у межах цього skill.

## Артефакти

Створи або перевір такі файли:

```text
requirements.txt
pytest.ini
tests/test_basic.py
run.sh
run.bat
ci.sh
ci.bat
```

Також після успішного запуску `ci.sh` або `ci.bat` має існувати:

```text
dist/
  hello.py
  add.py
```

### Залежності

`requirements.txt` повинен містити один, недубльований запис:

```text
pytest>=7
```

Не додавай однаковий рядок повторно під час повторного запуску.

### Конфігурація pytest

`pytest.ini` повинен містити секцію `[pytest]` з такими налаштуваннями:

```ini
[pytest]
pythonpath = src
testpaths = tests
```

### Тест

`tests/test_basic.py` повинен імпортувати `add` і містити тест із точною
перевіркою базового додавання:

```python
from add import add


def test_basic_addition() -> None:
    assert add(2, 3) == 5
```

### Скрипти запуску

`run.sh` — Bash-скрипт, який:

1. використовує `set -euo pipefail`;
2. створює `.venv` командою `python3 -m venv .venv`, лише якщо `.venv`
   ще не існує;
3. встановлює залежності через `.venv/bin/python -m pip install -r
   requirements.txt`;
4. запускає програму через `.venv/bin/python src/hello.py`.

Не використовуй `source`, `activate` або глобальний `python` після створення
середовища.

`run.bat` — Windows batch-скрипт, який:

1. створює `.venv` командою `python -m venv .venv`, лише якщо `.venv` ще не
   існує;
2. після кожного кроку перевіряє `%errorlevel%` і негайно завершується з
   ненульовим кодом при помилці;
3. встановлює залежності через `.venv\Scripts\python -m pip install -r
   requirements.txt`;
4. запускає програму через `.venv\Scripts\python src\hello.py`.

Не використовуй `activate` або глобальний інтерпретатор для встановлення
пакетів чи запуску програми.

### CI-скрипти

`ci.sh` — Bash CI-скрипт, який:

1. використовує `set -euo pipefail`;
2. створює `.venv` командою `python3 -m venv .venv`, якщо його немає;
3. встановлює залежності через `.venv/bin/python -m pip install -r
   requirements.txt`;
4. запускає `.venv/bin/python -m pytest -v`;
5. створює `dist/` і копіює до неї `src/hello.py` та `src/add.py`.

`ci.bat` — Windows CI-скрипт, який виконує ті самі кроки з командами
`python -m venv .venv`, `.venv\Scripts\python -m pip ...`,
`.venv\Scripts\python -m pytest -v` і копіюванням через `copy`. Після
кожного кроку обов'язково перевіряй `%errorlevel%`; при ненульовому значенні
завершуй скрипт негайно.

Усі виклики інтерпретатора після створення середовища повинні використовувати
лише `.venv/bin/python` або `.venv\Scripts\python`. Не активуй середовище.

## Процедура

1. Перевір поточний каталог, гілку, робоче дерево та наявність двох вхідних
   модулів.
2. Перевір кожен цільовий файл перед зміною.
3. Якщо файл відсутній, створи його з відповідним мінімальним вмістом.
4. Якщо файл існує і має очікуваний вміст, не змінюй його.
5. Якщо файл існує, але відрізняється, зупинись, повідом шлях і характер
   конфлікту; не перезаписуй файл.
6. Переконайся, що `.venv` виключена з Git-відстеження через запис `.venv/`
   у `.gitignore`. Не додавай `.venv` до індексу.
7. Після створення Bash-файлів забезпеч виконання:

   ```text
   git update-index --chmod=+x run.sh ci.sh
   ```

   Якщо файли ще не відстежуються, повідом про потребу додати їх до індексу
   окремою дозволеною операцією, не виконуючи небезпечних Git-команд.
8. Запусти перевірки, наведені нижче, і збережи їхній код завершення.
9. Покажи список змін і стислий diff. Не оголошуй роботу успішною при
   невдалій або пропущеній перевірці.

## Ідемпотентність і безпека

- Не перезаписуй наявні файли.
- Не перестворюй `.venv`, якщо каталог уже існує.
- Не дублюй `pytest>=7` або інші однакові рядки в `requirements.txt`.
- Не використовуй команди активації virtualenv.
- Не видаляй наявні файли та не очищай `dist/` без окремого дозволу.
- Не приховуй помилки скриптів і не продовжуй після невдалого кроку.

## Перевірки успішності

Виконай щонайменше:

```text
# Linux/macOS
./ci.sh
.venv/bin/python src/hello.py

# Windows
ci.bat
.venv\Scripts\python src\hello.py
```

У виводі тестів має бути успішний тест:

```text
test_basic_addition ... PASSED
```

Після CI підтвердь, що `dist/hello.py` існує та виводить:

```text
Hello, World!
```

Також перевір, що `.venv/` не відстежується Git, а Bash-скрипти мають
виконуваний режим.

## Приклад

Вхідні дані:

```text
src/hello.py: exists
src/add.py: exists
platform: Linux
```

Очікуваний результат:

```text
Created: requirements.txt
Created: pytest.ini
Created: tests/test_basic.py
Created: run.sh
Created: run.bat
Created: ci.sh
Created: ci.bat
Created: dist/hello.py
Created: dist/add.py
pytest: test_basic_addition PASSED
Output: Hello, World!
```

Для Windows очікується той самий результат із використанням `.venv\Scripts\python`
і `ci.bat`. Якщо всі файли вже відповідають вимогам, повідом:

```text
No changes required
```

Якщо, наприклад, `requirements.txt` існує та містить іншу версію pytest,
зупинись із повідомленням:

```text
Conflict: requirements.txt exists with different content; no files were overwritten.
```
