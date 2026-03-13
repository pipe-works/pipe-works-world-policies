"""Utilities for validating world-policy exchange repository structure."""

from pathlib import Path


def worlds_root(repo_root: Path) -> Path:
    """Return the canonical worlds directory for export artifacts."""
    return repo_root / "worlds"
