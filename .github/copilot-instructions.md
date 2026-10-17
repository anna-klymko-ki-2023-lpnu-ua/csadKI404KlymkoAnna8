## Repository scope

This repository is a VS Code Copilot customization project for a
cross-platform Python Hello World build agent. The primary custom agent is
[`build-engineer`](./agents/build-engineer.agent.md). Its skills and prompt
commands are the executable specification for the later project-generation
workflow.

The configuration-only `develop` branch is intended to contain agent
configuration and documentation only. When working on that branch, do not
create the generated project artifacts:

```text
src/
tests/
requirements.txt
pytest.ini
run.sh
run.bat
ci.yml
ci.sh
ci.bat
```

The repository overview is in
[`csadKI404KlymkoAnna8-develop/README.md`](../csadKI404KlymkoAnna8-develop/README.md);
the detailed stage model and artifact hand-offs are in
[`docs/architecture.md`](../docs/architecture.md). Keep those documents,
the custom agent, prompts, and skills consistent when changing the workflow.

The customization layers have distinct responsibilities: the
[`build-engineer` agent](./agents/build-engineer.agent.md) defines the role and
safety constraints, the [`skills/`](./skills/) define stage procedures, and
the [`prompts/`](./prompts/) expose user-facing commands. Prefer those
commands over manually reproducing a later stage so that prerequisite and
artifact checks remain intact.

## Workflow architecture

The `/init` prompt is a sequential fail-fast orchestrator:

1. [`git-init.prompt.md`](./prompts/git-init.prompt.md) validates the
   repository and configures `.gitignore`.
2. [`create-project.prompt.md`](./prompts/create-project.prompt.md) invokes
   `project-scaffold` with `language=Python` and `project_name=hello`, producing
   `src/hello.py` and `src/add.py`.
3. [`create-build.prompt.md`](./prompts/create-build.prompt.md) invokes
   `build-and-test`, producing dependencies, pytest configuration, tests,
   launch scripts, and local CI scripts.
4. [`create-actions.prompt.md`](./prompts/create-actions.prompt.md) invokes
   `github-actions`, producing `.github/workflows/ci.yml`.
5. [`check.prompt.md`](./prompts/check.prompt.md) performs the final
   read-only audit and must return `PASSED`.

Do not skip stages or run later stages in parallel. After each stage, verify
its expected artifacts. Stop immediately on a failure and report the command,
exit code, cause, unfinished work, and a safe remediation path.

## Skills and generated project contract

- [`project-scaffold`](./skills/project-scaffold/SKILL.md) accepts
  `language=Python` and `project_name=hello`. It defines the source module
  contract, including `add(a: int, b: int) -> int` and `Hello, World!`.
- [`build-and-test`](./skills/build-and-test/SKILL.md) defines
  `requirements.txt` with `pytest>=7`, `pytest.ini`, the
  `test_basic_addition` test, `run.sh`/`run.bat`, and `ci.sh`/`ci.bat`.
- [`github-actions`](./skills/github-actions/SKILL.md) defines the workflow
  matrix for `ubuntu-latest`, `windows-latest`, and `macos-latest`, with
  `fail-fast: false`.

Generated scripts must call the virtual-environment interpreter directly:

```text
# Linux/macOS
.venv/bin/python

# Windows
.venv\Scripts\python
```

Do not use environment activation. Bash scripts use `set -euo pipefail`;
Windows batch scripts check `%errorlevel%` after each step. The GitHub
workflow delegates build and test work exclusively to `./ci.sh` on Unix and
`ci.bat` on Windows; it must not contain direct `python`, `pip`, or `pytest`
commands.

## Build, test, and validation commands

The generated application and test files are not present on the current
branch, so these commands are applicable after the build stage creates them.
Use the repository scripts rather than reproducing their steps manually:

From VS Code Copilot Chat, use `/init` for the complete verified sequence.
Use `/git-init`, `/create-project`, `/create-build`, `/create-actions`, or
`/check` for individual stages; `/check` is read-only and must end with
`PASSED` before reporting the project as complete.

```text
# Linux/macOS: build, test, and populate dist/
./ci.sh

# Linux/macOS: run the complete test suite
.venv/bin/python -m pytest -v

# Linux/macOS: run one test
.venv/bin/python -m pytest -v tests/test_basic.py::test_basic_addition

# Linux/macOS: run the application
.venv/bin/python src/hello.py
```

```text
:: Windows: build, test, and populate dist/
ci.bat

:: Windows: run the complete test suite
.venv\Scripts\python -m pytest -v

:: Windows: run one test
.venv\Scripts\python -m pytest -v tests\test_basic.py::test_basic_addition

:: Windows: run the application
.venv\Scripts\python src\hello.py
```

Expected test output includes `test_basic_addition ... PASSED`, and the
application must print `Hello, World!`. There is no repository lint command
defined; do not invent one. For workflow validation, parse
`.github/workflows/ci.yml` with an available YAML validator and verify its
three-OS matrix, action versions, shell-specific script calls, and artifact
upload.

## Change conventions

- Read every target file before changing it.
- Preserve existing content when it already satisfies the relevant skill or
  prompt; do not overwrite a conflicting file silently.
- Make changes idempotently: do not duplicate `.gitignore` entries,
  requirements, workflow jobs, or workflow steps.
- Keep Ukrainian instructions and documentation consistent with the existing
  customization files; keep file names and command names in English.
- Use the exact paths and platform-specific interpreter paths defined by the
  skills.
- Surface command failures explicitly with the command, exit code, and cause.
  Never report success when a required check was skipped or failed.
- Do not delete files, rewrite Git history, force-push, alter branch
  protection, expose secrets, or transmit repository data externally.
- Before finishing, report changed files and a concise diff. Preserve
  unrelated worktree changes.

## Verification definition

The complete generated project is ready only when the final `/check` audit
returns `PASSED`, including a passing `test_basic_addition`, the expected
`Hello, World!` output, a valid three-OS workflow, correct `.gitignore`
exclusions, and no tracked build directories or secrets.