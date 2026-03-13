#!/usr/bin/env bash
set -euo pipefail

# Build the local-only _working area and the shared symlink used across
# pipe-works repos. This keeps scratch notes out of git while preserving
# a consistent operator workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_SHARED="$(cd "${REPO_ROOT}/.." && pwd)/_working_shared"
WORKING_SHARED_PATH="${WORKING_SHARED_PATH:-${DEFAULT_SHARED}}"

mkdir -p "${REPO_ROOT}/_working"
ln -sfn "${WORKING_SHARED_PATH}" "${REPO_ROOT}/_working/shared"

echo "Created local workspace scaffold:"
echo "  _working/"
echo "  _working/shared -> ${WORKING_SHARED_PATH}"
