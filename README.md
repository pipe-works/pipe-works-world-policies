# pipe-works-world-policies

Exchange repository for mud-server world policy publish/import artifacts.

## Purpose

- Keep canonical runtime authority in mud-server SQLite DB.
- Store exported policy artifacts for review and sharing.
- Provide a stable world/scoped artifact layout.

## Repository Layout

- `worlds/<world_id>/<scope>/publish_<manifest_hash>.json`
- `worlds/<world_id>/<scope>/latest.json`
- `src/pipeworks_world_policies/` minimal helper package for validation utilities
- `tests/` unit tests for repository helpers
- `tools/bootstrap_local_workspace.sh` local `_working` scaffold + symlink setup

## Local Setup

```bash
pyenv local pms
pyenv exec pip install -e ".[dev]"
pyenv exec pre-commit install
```

Create local-only working notes area and shared symlink:

```bash
./tools/bootstrap_local_workspace.sh
```

Optional custom shared notes path:

```bash
WORKING_SHARED_PATH=/absolute/path/to/_working_shared ./tools/bootstrap_local_workspace.sh
```

`_working/` is intentionally ignored by git.

## Quality Gates

```bash
pyenv exec ruff check src tests
pyenv exec black --check src tests
pyenv exec mypy src
PYTHONPATH=src pyenv exec pytest -q
```

## CI/CD

This repo is wired to organization reusable workflows:

- `.github/workflows/ci.yml`
- `.github/workflows/release-please.yml`
- `.github/workflows/dependency-update.yml`

Release automation files:

- `release-please-config.json`
- `.release-please-manifest.json`

## License

GPL-3.0-or-later (see `LICENSE`).
