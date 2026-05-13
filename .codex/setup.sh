#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export MAX_WORKERS="${MAX_WORKERS:-2}"

log() {
    printf '[codex-setup] %s\n' "$*"
}

ensure_uv() {
    if command -v uv >/dev/null 2>&1; then
        return
    fi

    log "installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
}

main() {
    cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

    ensure_uv

    log "syncing Python environment"
    uv sync --frozen

    log "checking ehrql is installed"
    uv run ehrql --version

    log "setup complete"
}

main "$@"
