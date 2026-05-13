# ehrql-codex

Minimal OpenSAFELY/ehrQL project.

## Setup

For Codex Cloud, use this setup command:

```sh
bash .codex/setup.sh
```

The setup script installs/syncs the `uv` environment and checks that the
`ehrql` CLI is available.

Alternatively, install the project-local locked environment:

```sh
uv sync
```

## Generate the dataset

After setup, run:

```sh
ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv
```

```sh
source .venv/bin/activate
ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv
```

If you used `uv sync`, run through `uv` or activate the virtual environment first:

```sh
uv run ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv
```

## Codex Universal Smoke Test

To test the Codex setup locally inside the reference Codex image:

```sh
bash scripts/smoke-codex-universal.sh
```

The same smoke test is also available as the `Codex Universal smoke test`
GitHub Actions workflow.
