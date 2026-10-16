---
name: github-actions
description: "Use when creating or validating a cross-platform GitHub Actions CI workflow for the Python Hello World project, including push and pull_request triggers, an Ubuntu/Windows/macOS matrix, local CI scripts, and uploaded dist artifacts."
argument-hint: "Generate or validate .github/workflows/ci.yml for develop and master."
user-invocable: true
disable-model-invocation: false
---

# GitHub Actions

## Призначення

Цей skill створює або перевіряє конфігурацію GitHub Actions для
кросплатформної перевірки Python-проєкту. Очікуваний артефакт — файл
`.github/workflows/ci.yml`. Застосовуй skill, коли потрібно налаштувати CI
для гілок `develop` і `master`, запустити локальні CI-скрипти на трьох
операційних системах і зберегти теку `dist/` як артефакт.

## Вхідні дані

Перед початком перевір:

```text
project_type=Python
workflow_path=.github/workflows/ci.yml
ci_scripts=ci.sh,ci.bat
artifact_directory=dist/
branches=develop,master
```

Переконайся, що локальні `ci.sh` і `ci.bat` вже передбачені проєктом. Цей
skill не замінює їх і не створює Python-модулі або CI-скрипти.

## Очікувана структура workflow

Файл `.github/workflows/ci.yml` повинен містити:

1. тригери `push` і `pull_request` лише для гілок `develop` та `master`;
2. одне завдання з матрицею `os`;
3. `fail-fast: false`;
4. ранерів `ubuntu-latest`, `windows-latest`, `macos-latest`;
5. послідовні кроки checkout, setup Python, локальний CI-скрипт і upload
   artifact;
6. Python `3.12`;
7. артефакт із каталогу `dist/` з унікальним ім'ям для кожного ранера та
   `if-no-files-found: error`.

Канонічний workflow:

```yaml
name: CI

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]

jobs:
  build-and-test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Run CI script on Unix
        if: runner.os != 'Windows'
        shell: bash
        run: ./ci.sh
      - name: Run CI script on Windows
        if: runner.os == 'Windows'
        shell: cmd
        run: ci.bat
      - name: Upload distribution
        uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

У workflow не додавай окремих кроків із командами `python`, `pip` або
`pytest`. Уся підготовка середовища, встановлення залежностей, тестування та
копіювання в `dist/` виконується локальними `ci.sh` і `ci.bat`.

## Процедура

1. Перевір гілку, робоче дерево та наявність локальних CI-скриптів.
2. Перевір, чи існує `.github/workflows/ci.yml`, і прочитай його перед
   зміною.
3. Якщо файл відсутній, створи каталог `.github/workflows/` і файл за
   канонічною структурою.
4. Якщо файл існує та відповідає вимогам, не змінюй його.
5. Якщо файл існує, але має інший вміст, повідом конфлікт і не перезаписуй
   його без окремого дозволу.
6. Переконайся, що Bash-скрипт має право виконання:

   ```text
   git update-index --chmod=+x ci.sh
   ```

   Якщо `ci.sh` ще не відстежується, повідом про це замість небезпечної або
   неочікуваної зміни індексу.
7. Перевір YAML, структуру матриці, дії, скрипти та артефакти.
8. Покажи список змін і стислий diff перед завершенням.

## Обмеження безпеки та змісту

- Не додавай у `ci.yml` паролі, ключі доступу, токени або інші секретні
  значення.
- Не використовуй прямі виклики `python`, `pip` чи `pytest` у `ci.yml`.
- Не обходь локальні `ci.sh` і `ci.bat` додатковими командами збірки.
- Не додавай інші операційні системи або зайві jobs без окремої вимоги.
- Не видаляй наявний workflow і не перезаписуй конфліктний файл мовчки.
- Не використовуй `shell: bash` для Windows; для Windows має бути
  `shell: cmd` і `run: ci.bat`.
- Для Linux і macOS використовуй `shell: bash` і `run: ./ci.sh`.

## Перевірки якості

Перевір синтаксис YAML доступним локальним валідатором. Якщо в середовищі
доступний Python із YAML-бібліотекою, можна виконати:

```text
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
```

Якщо цей валідатор недоступний, використай інший наявний YAML-інструмент і
повідом фактичний результат. Не встановлюй залежності лише для приховування
помилки валідації.

Окремо підтвердь:

- `push.branches` містить `develop` і `master`;
- `pull_request.branches` містить `develop` і `master`;
- є рівно один job із `strategy.fail-fast: false`;
- матриця містить усі три значення: `ubuntu-latest`, `windows-latest`,
  `macos-latest`;
- використано `actions/checkout`;
- використано `actions/setup-python@v5` з `python-version: "3.12"`;
- Unix-крок викликає лише `./ci.sh` через `shell: bash`;
- Windows-крок викликає лише `ci.bat` через `shell: cmd`;
- upload використовує `actions/upload-artifact@v4`, `path: dist/`,
  `name: hello-${{ matrix.os }}` та `if-no-files-found: error`;
- у тексті workflow немає згадок `token`, `password` або `secret`;
- Bash-скрипт має виконуваний режим або окремо зафіксовано причину, чому це
  ще не виконано.

## Приклад

Вхідні дані:

```text
project_type=Python
workflow_path=.github/workflows/ci.yml
ci_scripts=ci.sh,ci.bat
artifact_directory=dist/
branches=develop,master
```

Очікуваний результат:

```text
Created: .github/workflows/ci.yml
Validated: YAML syntax
Validated: ubuntu-latest, windows-latest, macos-latest matrix
Validated: Python 3.12 setup
Validated: local ci.sh/ci.bat execution
Validated: dist/ artifact upload
```

Якщо workflow уже відповідає всім вимогам, повідом:

```text
No changes required
```

Якщо YAML невалідний, відсутній ранер або знайдено заборонену пряму команду,
зупинись, покажи конкретну причину та не оголошуй CI готовим.
