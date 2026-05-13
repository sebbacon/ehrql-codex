# ehrql-codex

Minimal OpenSAFELY/ehrQL project.

## Setup

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
