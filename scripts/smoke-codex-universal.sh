#!/usr/bin/env bash
set -euo pipefail

IMAGE="${CODEX_UNIVERSAL_IMAGE:-ghcr.io/openai/codex-universal:latest}"
PLATFORM="${CODEX_UNIVERSAL_PLATFORM:-linux/amd64}"
WORKSPACE_NAME="$(basename "$(pwd)")"
CONTAINER_WORKSPACE="/workspace/${WORKSPACE_NAME}"
DOCKER_CONFIG_DIR="${DOCKER_CONFIG:-$(mktemp -d)}"

export DOCKER_CONFIG="${DOCKER_CONFIG_DIR}"

if ! docker info >/dev/null 2>&1; then
    echo "[smoke] local Docker daemon is not available" >&2
    echo "[smoke] start Docker or Colima, then re-run this script" >&2
    exit 1
fi

echo "[smoke] pulling ${IMAGE}"
docker pull --platform "${PLATFORM}" "${IMAGE}"

echo "[smoke] running setup and dataset generation inside ${IMAGE}"
docker run --rm --privileged \
    --platform "${PLATFORM}" \
    -e CODEX_ENV_PYTHON_VERSION=3.12 \
    -e MAX_WORKERS=2 \
    -e UV_PROJECT_ENVIRONMENT=/tmp/ehrql-codex-venv \
    -v "$(pwd):${CONTAINER_WORKSPACE}" \
    -w "${CONTAINER_WORKSPACE}" \
    "${IMAGE}" \
    bash -lc '
        set -euo pipefail
        trap "rm -f dataset.csv" EXIT
        bash .codex/setup.sh
        uv run opensafely exec ehrql:v1 generate-dataset analysis/dataset_definition.py --output dataset.csv
        test -s dataset.csv
        printf "[smoke] dataset rows: "
        wc -l < dataset.csv
    '
