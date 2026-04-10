# AGENTS.md

## Foundation Must-Dos (Org-Wide)

Read and apply these before repo-specific instructions:

- Local workspace path: `../.github/.github/docs/AGENT_FOUNDATION.md`
- Local workspace path: `../.github/.github/docs/TEST_TAGGING_AND_GITHUB_CHECKLIST.md`
- Canonical URL: `https://github.com/pipe-works/.github/blob/main/.github/docs/AGENT_FOUNDATION.md`
- Canonical URL: `https://github.com/pipe-works/.github/blob/main/.github/docs/TEST_TAGGING_AND_GITHUB_CHECKLIST.md`

Mandatory requirements:

1. Run the GitHub preflight checklist before any `gh` interaction, CI edits, or
   test-tag changes.
2. Preserve required checks (`All Checks Passed`, `Secret Scan (Gitleaks)`).
3. Do not weaken test-tag semantics to reduce runtime.
4. Keep CI optimization changes evidence-based (run IDs, timings, check states).

## Repo Identity

This repository publishes the Python package `pipe-works-world-policies` from
the workspace `pipe-works-world-policies`.

The current codebase is best understood as:

- an exchange repository for canonical published policy artifacts
- a very small Python helper package under `src/pipeworks_world_policies/`
- a repo whose most important contract is filesystem layout and artifact
  coherence, not a long-running application process

Do not treat this repository as the runtime authority for policy state.
Canonical runtime authority lives in `pipeworks_mud_server` SQLite policy
tables and activation rows. This repo stores exported artifacts for review,
sharing, and bootstrap import.

## Relationship To pipeworks_mud_server

This repo is operationally coupled to `pipeworks_mud_server` even though it is
not itself a service.

Important current behaviors in `pipeworks_mud_server`:

- `mud-server init-db` bootstraps world policy state from
  `worlds/<world_id>/world/latest.json`
- `mud-server import-policy-artifact --artifact-path <publish_*.json>` imports
  one canonical publish artifact into the runtime DB
- engine startup warns and skips axis bootstrap when no effective canonical
  manifest/axis activation has been imported for a world

That means this repository can affect whether host startup has usable canonical
policy state for worlds such as `pipeworks_web`, even though the runtime DB
remains authoritative after import.

The startup warning:

- `Axis policy bootstrap skipped for pipeworks_web: no effective canonical axis/manifest activation was found ...`

is not caused by this repo merely existing. It means the runtime DB on the
current host does not yet have an effective canonical activation imported for
that world. The normal remedies are:

- run `mud-server init-db` with artifact bootstrap enabled
- or run `mud-server import-policy-artifact --artifact-path <publish_*.json>`
  against the intended world artifact

## Repository Layout

The important checked-in layout is:

- `worlds/<world_id>/<scope>/publish_<manifest_hash>.json`
- `worlds/<world_id>/<scope>/latest.json`
- `src/pipeworks_world_policies/__init__.py`
- `tests/test_worlds_root.py`
- `tools/bootstrap_local_workspace.sh`
- `pyproject.toml`

Current checked-in world scopes are minimal and world-level:

- `worlds/daily_undertaking/world/`
- `worlds/pipeworks_web/world/`

There is no docs tree, no FastAPI app, no nginx/systemd deploy surface, and no
host-service runtime in this repository today.

## Artifact Contract

Treat the artifact layout as the real compatibility surface of this repo.

`latest.json` is a pointer record. It should remain coherent with one immutable
`publish_<manifest_hash>.json` file in the same scope directory.

Key invariants:

- `publish_<manifest_hash>.json` files are immutable snapshots
- `latest.json` selects the current snapshot for a scope
- `world_id`, `scope`, `manifest_hash`, and pointer fields must stay coherent
- do not rename or reshuffle scope directories casually
- do not hand-edit hashes, file names, or pointer fields unless the task is
  explicitly about repairing artifact integrity

The current `pipeworks_mud_server` bootstrap code resolves artifacts from
`latest.json` by trying:

- the absolute `artifact_path` if present
- the export-root-relative `artifact_path` if present and relative
- the sibling file with the same basename next to `latest.json`
- the sibling `artifact_file`

The intended checked-in contract is now:

- `artifact_file` names the sibling artifact file
- `artifact_path` is repo-relative, for example
  `worlds/<world_id>/<scope>/publish_<manifest_hash>.json`

Because of the fallback behavior, a stale absolute path from another machine
does not automatically break bootstrap as long as the sibling artifact file
exists and `artifact_file` is correct, but new checked-in pointers should not
use machine-specific absolute paths.

## Luminal Host Posture

Follow the current host policy in
`/home/aapark/dotfiles/docs/policies/luminal_host_service_topology_policy.md`
and the current PipeWorks map in
`/home/aapark/dotfiles/docs/project_maps/pipeworks.md`.

For this repository, that currently means:

- it should be treated as a PipeWorks repo in the Luminal workspace
- it is not automatically a hosted-service candidate
- do not invent an nginx hostname, systemd unit, or localhost-bound backend for
  this repo unless the task explicitly changes its classification
- host-preparation work should focus first on clone placement, reproducible
  Python environment needs, and artifact/bootstrap usefulness to
  `pipeworks_mud_server`

At the moment, this repo is better understood as a host-visible artifact source
than as a service rollout target.

Current Luminal interpreter position for this repo:

- the dedicated Luminal venv for this repo is
  `/srv/work/pipeworks/venvs/pw-world-policies`
- the current PipeWorks Luminal default interpreter baseline is Python `3.13`
- this repo should follow that Python `3.13` baseline on Luminal unless an
  explicit dependency-driven exception is documented later
- the current known PipeWorks exception is
  `/srv/work/_working/pipeworks-org-review/pipeworks-image-generator`, which is
  expected to stay on Python `3.12` because Linux GPU/ML compatibility for
  CUDA, PyTorch, and NVIDIA-adjacent packages is more predictable there

## Local Setup And Commands

The current repo README documents local developer setup via `pyenv`:

```bash
pyenv local pms
pyenv exec pip install -e '.[dev]'
pyenv exec pre-commit install
./tools/bootstrap_local_workspace.sh
```

If docs tooling is needed:

```bash
pyenv exec pip install -e '.[dev,docs]'
```

Quality gates from the current repo state:

```bash
pyenv exec ruff check src tests
pyenv exec black --check src tests
pyenv exec mypy src
PYTHONPATH=src pyenv exec pytest -q
pyenv exec python -m build --no-isolation
```

If you are doing Luminal-specific preparation work, do not assume that `pyenv`
is the long-term host model. Any dedicated Luminal venv path should be an
explicit decision recorded in the relevant MOC or runbook rather than inferred
from the current local README.

## Project Structure

The Python package surface is intentionally tiny:

- `src/pipeworks_world_policies/__init__.py`
  - currently exposes `worlds_root(repo_root: Path) -> Path`

The current tests are equally small:

- `tests/test_worlds_root.py`
  - verifies the canonical `worlds/` helper path

Do not assume there is a larger package API hiding elsewhere. Most meaningful
changes in this repo will affect artifact layout, validation helpers, tests, or
operator workflow rather than a broad Python application surface.

## Coding Style And Change Guidance

Follow the tool configuration in `pyproject.toml`:

- Black line length is `100`
- Ruff currently targets Python `3.12` syntax compatibility in repo config,
  while the standard Luminal host venv baseline for PipeWorks repos is Python
  `3.13`
- Mypy is enabled for `src`
- pytest configuration lives in `pyproject.toml`

Repo-specific guidance:

- prefer small, explicit filesystem helpers over speculative abstractions
- keep helper code path-focused and deterministic
- preserve artifact naming and directory conventions unless the task explicitly
  redefines the exchange format
- when changing artifact structure, cross-check impact on
  `pipeworks_mud_server` bootstrap and import flows before merging
- when in doubt, treat artifact compatibility as more important than
  adding convenience code

## Testing Guidelines

Current pytest markers configured in `pyproject.toml` are:

- `unit`
- `integration`
- `slow`
- `requires_model`

The current test suite is small, but changes should still be validated
deliberately:

- update or add unit tests for any filesystem helper or validation logic
- add tests before changing artifact resolution assumptions
- if a change is meant to affect Luminal bootstrap behavior, verify the
  expected `pipeworks_mud_server` import/bootstrap path in the sibling repo

Do not remove markers or lower test rigor simply because this repo looks small.

## Release, CI, And Automation

This repo currently carries:

- GitHub Actions CI
- release automation via `release-please-config.json` and
  `.release-please-manifest.json`
- coverage reporting via `codecov.yml`
- pre-commit hooks via `.pre-commit-config.yaml`

When touching CI, release, or packaging behavior:

- preserve release-please inputs and package identity
- do not casually rename the repo/package/workspace surfaces
- keep the repo usable as a deterministic artifact exchange repo, not just a
  Python helper package
