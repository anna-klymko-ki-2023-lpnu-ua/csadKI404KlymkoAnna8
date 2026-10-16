# Архітектура AI-агента

## 1. Призначення агента

AI-агент `build-engineer` автоматизує повний цикл підготовки
кросплатформного Python-проєкту Hello World. Він вирішує такі задачі:

- ініціалізація та перевірка Git-репозиторію;
- безпечне налаштування `.gitignore`;
- створення базової структури Python-проєкту;
- підготовка модулів `src/hello.py` і `src/add.py`;
- налаштування віртуального середовища `.venv`;
- створення залежностей, тестів і конфігурації `pytest`;
- підготовка скриптів запуску для Linux/macOS і Windows;
- автоматизація локального CI та створення дистрибутива `dist/`;
- налаштування GitHub Actions для Ubuntu, Windows і macOS;
- комплексний read-only аудит структури, тестів, CI та безпеки.

Агент працює ідемпотентно: перед зміною перевіряє наявність і вміст файла,
не перезаписує конфліктні файли та повідомляє про невідповідності.

## 2. Модуль скілів (skills)

Skills є спеціалізованими модулями процедурних інструкцій. Вони
завантажуються агентом за потреби та відповідають за окремі етапи:

| Skill | Файл | Зональна відповідальність |
|---|---|---|
| `project-scaffold` | [`SKILL.md`](../.github/skills/project-scaffold/SKILL.md) | Ініціалізація структури Python-проєкту, `src/`, `tests/`, `docs/` і README. |
| `build-and-test` | [`SKILL.md`](../.github/skills/build-and-test/SKILL.md) | Залежності, `pytest`, `.venv`, локальні скрипти запуску та CI-скрипти. |
| `github-actions` | [`SKILL.md`](../.github/skills/github-actions/SKILL.md) | Workflow GitHub Actions, матриця ОС і завантаження артефактів. |

`project-scaffold` приймає параметри `language=Python` і
`project_name=hello`. Наступні skills використовують створені модулі як
вхідні дані та передають результати наступному етапу.

## 3. Командний інтерфейс (commands)

Користувач запускає одноцільові prompt-команди через VS Code Copilot Chat:

| Команда | Prompt | Призначення |
|---|---|---|
| `/git-init` | [`git-init.prompt.md`](../.github/prompts/git-init.prompt.md) | Перевірка Git-репозиторію та ідемпотентне налаштування `.gitignore`. |
| `/create-project` | [`create-project.prompt.md`](../.github/prompts/create-project.prompt.md) | Виконання `project-scaffold` і створення базової структури. |
| `/create-build` | [`create-build.prompt.md`](../.github/prompts/create-build.prompt.md) | Виконання `build-and-test`, підготовка тестів, залежностей і скриптів. |
| `/create-actions` | [`create-actions.prompt.md`](../.github/prompts/create-actions.prompt.md) | Виконання `github-actions` і створення workflow CI. |
| `/check` | [`check.prompt.md`](../.github/prompts/check.prompt.md) | Read-only комплексна перевірка з таблицею `PASS/FAIL`. |
| `/init` | [`init.prompt.md`](../.github/prompts/init.prompt.md) | Послідовна оркестрація всіх попередніх команд. |

Окремі команди можна виконувати для конкретного етапу. Команда `/init`
призначена для повного сценарію з контрольними перевірками між етапами.

## 4. Потік даних між етапами

Потік артефактів має лінійну структуру:

```text
project_name=hello
        |
        v
project-scaffold
        |
        v
src/hello.py + src/add.py
        |
        v
build-and-test
        |
        +--> requirements.txt
        +--> pytest.ini
        +--> tests/test_basic.py
        +--> run.sh + run.bat
        +--> ci.sh + ci.bat
        |
        v
github-actions
        |
        v
.github/workflows/ci.yml
```

### Етап 1: параметри та початкова структура

Користувач або prompt передає:

```text
language=Python
project_name=hello
```

Skill `project-scaffold` перевіряє робочий каталог і створює відсутні
елементи:

- `src/hello.py`, який використовує `add` і друкує `Hello, World!`;
- `src/add.py` з функцією `add(a: int, b: int) -> int`;
- порожні каталоги `tests/` і `docs/`;
- `README.md`, якщо він відсутній.

### Етап 2: збірка та тестування

Skill `build-and-test` отримує `src/hello.py` і `src/add.py` та готує:

- `requirements.txt` із `pytest>=7`;
- `pytest.ini` із `pythonpath = src` і `testpaths = tests`;
- `tests/test_basic.py` із тестом `test_basic_addition`;
- `run.sh` і `run.bat` для локального запуску;
- `ci.sh` і `ci.bat` для тестування та копіювання модулів у `dist/`.

Інтерпретатор викликається без активації середовища: через
`.venv/bin/python` на Linux/macOS або `.venv\Scripts\python` на Windows.

### Етап 3: автоматизація CI

Skill `github-actions` використовує `ci.sh` і `ci.bat` як єдині локальні
точки запуску збірки. Він формує `.github/workflows/ci.yml` із:

- подіями `push` і `pull_request` для `develop` та `master`;
- одним job і матрицею `ubuntu-latest`, `windows-latest`,
  `macos-latest`;
- `fail-fast: false`;
- `actions/checkout`, `actions/setup-python@v5` з Python `3.12`;
- умовним викликом `./ci.sh` або `ci.bat`;
- завантаженням `dist/` як окремого артефакту для кожної ОС.

Workflow не містить прямих команд `python`, `pip` або `pytest`; ці операції
інкапсулюються в локальних CI-скриптах.

## 5. Логіка оркестрації та відмовостійкість

Команда `/init` працює як послідовний оркестратор:

1. перевіряє передумови та доступність усіх prompt-файлів;
2. виконує `/git-init`;
3. перевіряє `.gitignore` і стан Git;
4. виконує `/create-project`;
5. перевіряє `src/hello.py` і `src/add.py`;
6. виконує `/create-build`;
7. перевіряє залежності, тест і локальні скрипти;
8. виконує `/create-actions`;
9. перевіряє `.github/workflows/ci.yml`;
10. виконує `/check`;
11. оголошує загальний успіх лише за статусу `PASSED`.

Етапи не запускаються паралельно. Після кожного етапу оркестратор очікує
підтвердження результату. Якщо будь-яка команда або перевірка завершується
помилкою, виконання негайно зупиняється. Наступні етапи отримують статус
`NOT RUN`, а звіт містить:

- номер і назву проблемного кроку;
- prompt або skill, який виконувався;
- невдалу команду чи перевірку;
- код завершення та причину;
- незавершені артефакти;
- безпечний шлях виправлення.

Повторний запуск не має дублювати рядки, jobs, steps або файли. Наявний
файл спочатку порівнюється з очікуваним вмістом. При конфлікті агент
зупиняється та не перезаписує файл.

## 6. Структурна таблиця ролей

| Роль | Розташування | Файл або група файлів | Відповідальність |
|---|---|---|---|
| Агент | `.github/agents/` | [`build-engineer.agent.md`](../.github/agents/build-engineer.agent.md) | Персона, інструменти, правила безпеки та координація skills. |
| Skill | `.github/skills/project-scaffold/` | [`SKILL.md`](../.github/skills/project-scaffold/SKILL.md) | Базова структура Python-проєкту. |
| Skill | `.github/skills/build-and-test/` | [`SKILL.md`](../.github/skills/build-and-test/SKILL.md) | Збірка, залежності, тести й локальні скрипти. |
| Skill | `.github/skills/github-actions/` | [`SKILL.md`](../.github/skills/github-actions/SKILL.md) | GitHub Actions workflow та CI-артефакти. |
| Команда | `.github/prompts/` | `git-init.prompt.md` | Git і `.gitignore`. |
| Команда | `.github/prompts/` | `create-project.prompt.md` | Запуск scaffolding. |
| Команда | `.github/prompts/` | `create-build.prompt.md` | Запуск build-and-test. |
| Команда | `.github/prompts/` | `create-actions.prompt.md` | Запуск GitHub Actions setup. |
| Команда | `.github/prompts/` | `check.prompt.md` | Read-only аудит. |
| Оркестратор | `.github/prompts/` | `init.prompt.md` | Послідовний запуск усього сценарію. |

## 7. Технологічна примітка

Архітектура сумісна з форматом кастомізації VS Code Copilot:

- кастомний агент зберігається як `.agent.md` у `.github/agents/`;
- on-demand skills зберігаються як `SKILL.md` у
  `.github/skills/<skill-name>/`;
- файл-промпти зберігаються як `.prompt.md` у `.github/prompts/`;
- YAML frontmatter визначає `description`, `name` або `agent` відповідно
  до типу customization-файла;
- відносні посилання між prompt-файлами та skills підтримують навігацію
  всередині репозиторію;
- команди доступні через VS Code Copilot Chat і можуть бути обрані як
  slash-команди;
- `build-engineer.agent.md` використовується як цільовий custom agent для
  prompt-файлів через поле `agent: "build-engineer"`.

Таким чином, `.github/agents/`, `.github/skills/` і `.github/prompts/`
утворюють узгоджену систему: агент визначає роль, skills описують
багатоетапні процедури, а prompts надають користувачу керований командний
інтерфейс.
