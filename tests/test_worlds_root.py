"""Tests for repository layout helpers."""

from pathlib import Path

from pipeworks_world_policies import worlds_root


def test_worlds_root_points_to_worlds_directory() -> None:
    """The helper should always resolve to the worlds directory under repo root."""
    root = Path("/tmp/repo")
    assert worlds_root(root) == Path("/tmp/repo/worlds")
