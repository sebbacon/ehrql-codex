#!/usr/bin/env bash
set -euo pipefail

IMAGE="${CODEX_UNIVERSAL_IMAGE:-ghcr.io/openai/codex-universal:latest}"
WORKSPACE_NAME="$(basename "$(pwd)")"
CONTAINER_WORKSPACE="/workspace/${WORKSPACE_NAME}"

echo "[smoke] running setup and dataset generation inside ${IMAGE}"
docker run --rm \
    -e CODEX_ENV_PYTHON_VERSION=3.13 \
    -e MAX_WORKERS=2 \
    -e UV_PROJECT_ENVIRONMENT=/tmp/ehrql-codex-venv \
    -v "$(pwd):${CONTAINER_WORKSPACE}" \
    -w "${CONTAINER_WORKSPACE}" \
    "${IMAGE}" \
    -lc '
        set -euo pipefail
        trap "rm -f dataset.csv" EXIT
        bash .codex/setup.sh
        uv run ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv
        test -s dataset.csv
        printf "[smoke] dataset rows: "
        wc -l < dataset.csv
    '
