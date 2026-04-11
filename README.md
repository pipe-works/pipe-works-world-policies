[![CI](https://github.com/pipe-works/pipe-works-world-policies/actions/workflows/ci.yml/badge.svg)](https://github.com/pipe-works/pipe-works-world-policies/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/pipe-works/pipe-works-world-policies/branch/main/graph/badge.svg)](https://codecov.io/gh/pipe-works/pipe-works-world-policies) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Python 3.12+](https://img.shields.io/badge/python-3.12+-blue.svg)](https://www.python.org/downloads/) [![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black) [![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)

# pipe-works-world-policies

`pipe-works-world-policies` is the exchange repository for published world
policy artifacts used by PipeWorks runtime services. It stores reviewable,
versioned export outputs while leaving canonical runtime activation state in
`pipeworks_mud_server`.

## PipeWorks Workspace

These repositories are designed to live inside a shared PipeWorks workspace
rooted at `/srv/work/pipeworks`.

- `repos/` contains source checkouts only.
- `venvs/` contains per-project virtual environments such as `pw-mud-server`.
- `runtime/` contains mutable runtime state such as databases, exports, session
  files, and caches.
- `logs/` contains service-owned log output when a project writes logs outside
  the process manager.
- `config/` contains workspace-level configuration files that should not be
  treated as source.
- `bin/` contains optional workspace helper scripts.
- `home/` is reserved for workspace-local user data when a project needs it.

Across the PipeWorks ecosphere, the rule is simple: keep source in `repos/`,
keep mutable state outside the repo checkout, and use explicit paths between
repos when one project depends on another.

## What This Repo Owns

This repository is the source of truth for:

- published world-policy exchange artifacts under `worlds/`
- the stable artifact layout consumed by bootstrap/import flows
- lightweight helper code for validating repository structure
- local tooling such as `_working` bootstrap support

This repository does not own:

- canonical runtime policy activation state
- mud-server policy CRUD APIs
- in-repo authoring UIs or web services

## Repository Layout

- `worlds/<world_id>/<scope>/publish_<manifest_hash>.json` versioned published
  artifacts
- `worlds/<world_id>/<scope>/latest.json` stable pointer to the active published
  artifact for that scope
- `src/pipeworks_world_policies/` minimal helper package
- `tests/` repository helper tests
- `tools/bootstrap_local_workspace.sh` local `_working` bootstrap helper

## Role In The Ecosystem

The intended flow is:

1. policy objects are authored and managed through canonical mud-server APIs
2. publish/export flows produce artifact files into this repo
3. runtime bootstrap or explicit import flows read those files back into
   `pipeworks_mud_server`

This keeps artifact exchange reviewable without pretending the artifact repo is
the runtime authority.

## Quick Start

Create a dedicated workspace venv and install the helper package:

```bash
python3 -m venv /srv/work/pipeworks/venvs/pw-world-policies
/srv/work/pipeworks/venvs/pw-world-policies/bin/pip install -e ".[dev]"
```

If you need the docs toolchain too:

```bash
/srv/work/pipeworks/venvs/pw-world-policies/bin/pip install -e ".[dev,docs]"
```

Bootstrap the local `_working` area:

```bash
./tools/bootstrap_local_workspace.sh
```

Or point it at an explicit shared-notes location:

```bash
WORKING_SHARED_PATH=/srv/work/pipeworks/home/_working_shared \
./tools/bootstrap_local_workspace.sh
```

## Using The Repo With mud-server

Workspace-backed mud-server runs should point `MUD_POLICY_EXPORTS_ROOT` at this
repo:

```bash
export MUD_POLICY_EXPORTS_ROOT=/srv/work/pipeworks/repos/pipe-works-world-policies
```

That allows `mud-server init-db` and explicit
`mud-server import-policy-artifact --artifact-path ...` flows to resolve
published artifacts without depending on an implicit current working directory.

## Validation

Run the main checks from the repo root:

```bash
/srv/work/pipeworks/venvs/pw-world-policies/bin/ruff check src tests
/srv/work/pipeworks/venvs/pw-world-policies/bin/black --check src tests
/srv/work/pipeworks/venvs/pw-world-policies/bin/mypy src
PYTHONPATH=src /srv/work/pipeworks/venvs/pw-world-policies/bin/pytest -q
/srv/work/pipeworks/venvs/pw-world-policies/bin/python -m build --no-isolation
```

## Documentation

The repo is intentionally lightweight. Most detailed policy behavior is
documented in the runtime and authoring repos that consume these artifacts.

## License

[GPL-3.0-or-later](LICENSE)
