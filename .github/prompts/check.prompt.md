---
description: "Run a read-only comprehensive audit of the Python project, agent customizations, skills, scripts, tests, and CI configuration."
agent: "build-engineer"
argument-hint: "Виконайте повний аудит проєкту та виведіть таблицю PASS/FAIL."
---

# Check

Виконай комплексний аудит репозиторію та його AI-agent customization файлів.
Результат подай у таблиці `PASS`/`FAIL` із коротким доказом для кожного
критерію.

## Передумови

Перед початком перевір:

- повну структуру Python-проєкту;
- маніфест build engineer;
- усі три skills;
- локальні скрипти запуску та CI;
- доступність Git і Python у поточному середовищі.

Очікувані customization-файли:

```text
.github/agents/build-engineer.agent.md
.github/skills/project-scaffold/SKILL.md
.github/skills/build-and-test/SKILL.md
.github/skills/github-actions/SKILL.md
```

## Режим роботи: ТІЛЬКИ ЧИТАННЯ

Цей prompt не має права створювати, редагувати, видаляти, перейменовувати
або форматувати файли проєкту. Не змінюй `.gitignore`, Git index, права
доступу, вихідний код, тести, конфігурацію чи workflow.

Єдині дозволені зміни — створення або використання тимчасових каталогів
`.venv/` і `.pytest_cache/`, якщо вони вже передбачені `.gitignore`. Не
виконуй команди, що створюють `dist/`, оновлюють requirements або змінюють
інші файли. Зокрема, не запускай `ci.sh`, `ci.bat`, `run.sh` чи `run.bat`,
якщо їхнє виконання змінює файли проєкту.

Перед початком зафіксуй початковий `git status --short`, а після завершення
порівняй його з фінальним станом. Будь-які зміни поза дозволеними
тимчасовими каталогами мають бути позначені як FAIL і пояснені.

## Дії та перевірки

### 1. Customization і документація

Перевір:

- існування `.github/agents/build-engineer.agent.md`;
- існування всіх трьох `SKILL.md`;
- наявність у кожного skill розділів `Вхід`, `Вихід` і `Перевірки`
  або їхніх еквівалентних заголовків;
- коректність YAML frontmatter у manifest та skills;
- відповідність назв skills їхнім каталогам.

### 2. Ключові файли проєкту

Перевір існування кожного файла:

```text
src/hello.py
src/add.py
tests/test_basic.py
requirements.txt
pytest.ini
run.sh
run.bat
ci.sh
ci.bat
```

Зчитуй вміст без змін. Перевір, що `pytest.ini` має секцію `[pytest]`,
`pythonpath = src` і `testpaths = tests`, а тест містить
`test_basic_addition` з перевіркою `add(2, 3) == 5`.

### 3. Віртуальне середовище та залежності

Якщо `.venv/` відсутня, її дозволено створити як тимчасовий каталог:

```text
# Linux/macOS
python3 -m venv .venv

# Windows
python -m venv .venv
```

Інсталюй залежності лише у `.venv`, не використовуючи `activate` і не
змінюючи `requirements.txt`:

```text
# Linux/macOS
.venv/bin/python -m pip install -r requirements.txt

# Windows
.venv\Scripts\python -m pip install -r requirements.txt
```

Зафіксуй код завершення та результат. Якщо середовище вже існує, не
перестворюй його.

### 4. Тести та запуск

Запусти тільки через інтерпретатор `.venv`:

```text
# Linux/macOS
.venv/bin/python -m pytest -v
.venv/bin/python src/hello.py

# Windows
.venv\Scripts\python -m pytest -v
.venv\Scripts\python src\hello.py
```

Познач `PASS` для тестів лише якщо `test_basic_addition` має статус
`PASSED`. Познач `PASS` для запуску лише якщо стандартний вивід містить
точно `Hello, World!`.

### 5. CI workflow

Якщо `.github/workflows/ci.yml` існує, перевір його без редагування:

- YAML синтаксис валідний;
- матриця містить `ubuntu-latest`, `windows-latest` і `macos-latest`;
- workflow викликає лише `./ci.sh` для Unix і `ci.bat` для Windows;
- у workflow немає прямих команд `python`, `pip` або `pytest`;
- наявні checkout, setup Python і завантаження `dist/`.

Не запускай workflow або локальні CI-скрипти під час цього read-only аудиту,
якщо вони створюють `dist/` чи інші файли проєкту.

### 6. Git і безпека

Перевір:

```text
git status --short
git ls-files
git check-ignore -v .venv/ .pytest_cache/ dist/ __pycache__/
```

У `git ls-files` не повинні потрапляти будівельні теки або секрети:

```text
.venv/
venv/
dist/
build/
out/
__pycache__/
.pytest_cache/
.env
*.pem
*.key
```

Перевір, що `.gitignore` містить необхідні виключення без дублювання:
`build/`, `dist/`, `out/`, `.vs/`, `.venv/`, `venv/`, `__pycache__/`,
`*.pyc`, `.pytest_cache/`, `.env`, `*.pem`, `*.key`.

## Формат звіту

Виведи таблицю такого формату:

```text
| Критерій | Статус | Доказ або проблема |
|---|---|---|
| Manifest і три skills | PASS/FAIL | шлях або причина |
| Розділи skills | PASS/FAIL | перевірені заголовки |
| Ключові файли | PASS/FAIL | список відсутніх файлів |
| Віртуальне середовище і залежності | PASS/FAIL | команда і код |
| test_basic_addition | PASS/FAIL | результат pytest |
| Запуск hello.py | PASS/FAIL | фактичний вивід |
| ci.yml | PASS/FAIL | YAML, матриця, скрипти |
| Git-файли і секрети | PASS/FAIL | результат git ls-files |
| .gitignore | PASS/FAIL | відсутні або дубльовані правила |
| Read-only стан | PASS/FAIL | порівняння git status |
```

## Критерії завершення

- Якщо хоча б один критерій має `FAIL`, загальний статус — `FAILED`.
  Вкажи кожну проблему та безпечний наступний крок, не виправляючи її
  автоматично.
- Якщо всі критерії мають `PASS`, загальний статус — `PASSED`.
- Не називай аудит успішним через відсутність помилки команди, якщо
  відповідний критерій не перевірено фактично.
- Повідом фінальний `git status` і підтвердь, що жоден файл проєкту не було
  змінено.

## Повідомлення про помилку

Для кожного збою вкажи команду або файл, код завершення (якщо є), коротку
причину та вплив на критерій. Якщо перевірка неможлива, познач її `FAIL`, а
не `PASS` і не використовуй мовчазні припущення. Негайно зупини небезпечну
операцію, не продовжуй після помилки та не створюй виправлень у read-only
режимі.
