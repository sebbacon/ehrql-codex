#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export MAX_WORKERS="${MAX_WORKERS:-2}"

log() {
    printf '[codex-setup] %s\n' "$*"
}

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        log "need root privileges to run: $*"
        return 1
    fi
}

ensure_uv() {
    if command -v uv >/dev/null 2>&1; then
        return
    fi

    log "installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
}

ensure_docker_cli() {
    if command -v docker >/dev/null 2>&1; then
        return
    fi

    if [ -f /etc/os-release ] && grep -qi '^ID=ubuntu' /etc/os-release; then
        log "installing Docker from Ubuntu packages"
        run_as_root apt-get update
        run_as_root apt-get install -y docker.io iptables ca-certificates
        return
    fi

    log "docker is not installed and this script only auto-installs it on Ubuntu"
    return 1
}

wait_for_docker() {
    for _ in $(seq 1 45); do
        if docker info >/dev/null 2>&1; then
            return 0
        fi
        if [ "$(id -u)" -ne 0 ] && run_as_root docker info >/dev/null 2>&1; then
            run_as_root chmod 666 /var/run/docker.sock
            if docker info >/dev/null 2>&1; then
                return 0
            fi
        fi
        sleep 1
    done
    return 1
}

start_docker_daemon() {
    if docker info >/dev/null 2>&1; then
        return
    fi

    log "starting Docker daemon"
    run_as_root mkdir -p /var/run /var/lib/docker

    if command -v service >/dev/null 2>&1 && run_as_root service docker start >/tmp/codex-service-docker.log 2>&1; then
        if wait_for_docker; then
            return
        fi
    fi

    if pgrep dockerd >/dev/null 2>&1; then
        if wait_for_docker; then
            return
        fi
    else
        if ! command -v dockerd >/dev/null 2>&1; then
            log "docker CLI is installed, but no daemon is reachable and dockerd is not available"
            return 1
        fi
        run_as_root dockerd \
            --host=unix:///var/run/docker.sock \
            --storage-driver="${DOCKER_STORAGE_DRIVER:-vfs}" \
            >/tmp/codex-dockerd.log 2>&1 &
    fi

    if wait_for_docker; then
        return
    fi

    log "Docker did not become ready. If this is running in a container, it likely needs privileged/DinD support."
    log "Recent dockerd log:"
    tail -n 80 /tmp/codex-dockerd.log 2>/dev/null || true
    return 1
}

main() {
    cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

    ensure_uv
    ensure_docker_cli
    start_docker_daemon

    log "syncing Python environment"
    uv sync --frozen

    log "pulling OpenSAFELY ehrql:v1 image"
    uv run opensafely pull --force ehrql:v1

    log "checking OpenSAFELY can execute inside Docker"
    uv run opensafely exec --entrypoint python ehrql:v1 --version

    log "setup complete"
}

main "$@"
