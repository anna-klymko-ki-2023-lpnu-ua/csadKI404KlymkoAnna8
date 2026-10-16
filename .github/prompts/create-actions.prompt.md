---
description: "Create and validate the cross-platform GitHub Actions workflow using the repository github-actions skill."
agent: "build-engineer"
argument-hint: "Створіть або перевірте workflow .github/workflows/ci.yml."
---

# Create Actions

Налаштуй кросплатформний GitHub Actions workflow для Python-проєкту,
використовуючи skill
[`github-actions`](../skills/github-actions/SKILL.md).

## Передумови

Перед початком перевір, що локальні скрипти існують і доступні:

```text
ci.sh
ci.bat
```

Для `ci.sh` також перевір виконуваний режим. Якщо скрипт відсутній,
недоступний або не має потрібних прав, зупинися та повідом причину.

## Дії

1. Завантаж і виконай усі інструкції
   [`github-actions`](../skills/github-actions/SKILL.md).
2. Перевір наявний `.github/workflows/ci.yml` перед зміною.
3. Створи каталог `.github/workflows/`, якщо він відсутній.
4. Створи або коректно онови workflow відповідно до вимог skill.
5. Переконайся, що Unix використовує `shell: bash` і `./ci.sh`, а Windows —
   `shell: cmd` і `ci.bat`.
6. Перед завершенням покажи список змін і стислий diff.

## Очікуваний артефакт

Після виконання має існувати:

```text
.github/workflows/ci.yml
```

Workflow повинен містити тригери для `develop` і `master`, один job із
матрицею `ubuntu-latest`, `windows-latest`, `macos-latest`, а також
завантаження `dist/` як унікального артефакту для кожної ОС.

## Команди перевірки

1. Перевір валідність YAML доступним локальним валідатором. За наявності
   Python із YAML-бібліотекою використай:

   ```text
   python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
   ```

2. Підтвердь у `ci.yml` наявність усіх значень матриці:

   ```text
   ubuntu-latest
   windows-latest
   macos-latest
   ```

3. Перевір, що workflow викликає лише локальні скрипти:

   ```text
   ./ci.sh
   ci.bat
   ```

   Не допускай у `run` прямих команд `python`, `pip` або `pytest`.
4. Перевір наявність `actions/checkout`, `actions/setup-python@v5` з Python
   `3.12` та `actions/upload-artifact@v4` із `path: dist/`.

Якщо локальний YAML-валідатор недоступний, повідом це явно та використай
інший наявний спосіб перевірки. Не оголошуй workflow валідним без фактичної
перевірки.

## Повідомлення про помилку

У разі будь-якого збою:

- негайно зупинися;
- вкажи команду, що завершилася невдало, код завершення та причину;
- повідом незавершені перевірки або зміни;
- не оголошуй workflow готовим;
- не обходь помилку додатковими командами збірки.

Якщо наявний `ci.yml` відрізняється від очікуваного, не перезаписуй його
мовчки. Повідом конфлікт і запропонуй окреме рішення.

## Ідемпотентність і безпека

- Повторний запуск не повинен дублювати jobs, steps, тригери або артефакти.
- Якщо файл уже відповідає вимогам, залиш його без змін і повідом
  `No changes required`.
- Під час оновлення зберігай сумісні наявні налаштування.
- Не додавай секрети, токени, паролі або ключі до workflow.
- Не видаляй наявні робочі файли чи конфігурації без окремого дозволу.
