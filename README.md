# ehrql-codex

Minimal OpenSAFELY/ehrQL project.

## Setup

For Codex Cloud, use this setup command:

```sh
bash .codex/setup.sh
```

The setup script installs/syncs the `uv` environment, ensures Docker is
available, starts a nested Docker daemon when needed, pulls `ehrql:v1`, and
checks that OpenSAFELY can execute inside Docker.

For the exact `opensafely ...` command, install the CLI with `uv`:

```sh
uv tool install opensafely==1.56.8
```

Alternatively, install the project-local locked environment:

```sh
uv sync
```

## Generate the dataset

After setup, run:

```sh
opensafely exec ehrql:v1 generate-dataset analysis/dataset_definition.py --output dataset.csv
```

If you used `uv sync`, run through `uv` or activate the virtual environment first:

```sh
uv run opensafely exec ehrql:v1 generate-dataset analysis/dataset_definition.py --output dataset.csv
```

```sh
source .venv/bin/activate
opensafely exec ehrql:v1 generate-dataset analysis/dataset_definition.py --output dataset.csv
```

## Codex Universal Smoke Test

To test the Codex setup locally inside the reference Codex image:

```sh
bash scripts/smoke-codex-universal.sh
```

This pulls `ghcr.io/openai/codex-universal:latest` and runs it with
`--privileged` so Docker-in-Docker can start inside the container.

The same smoke test is also available as the `Codex Universal smoke test`
GitHub Actions workflow.
