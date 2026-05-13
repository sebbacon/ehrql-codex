---
name: ehrql-dataset-authoring
description: Use when writing or editing `analysis/dataset_definition.py` or related assurance tests in this repo. This skill explains the local ehrQL workflow, where the dataset definition lives, how to run `ehrql generate-dataset` for dummy data, how to organize and run assurance tests, and what each bundled upstream ehrQL doc covers.
---

# ehrQL Dataset Authoring

Use this skill when the user wants this repo's dataset definition changed to match a study spec or natural-language prompt.

## Local contract

- Main file: `analysis/dataset_definition.py`
- Primary job: write or update ehrQL dataset definitions from the user's spec.
- The standard local smoke test is generating dummy data from that file.
- The stronger validation path is adding assurance tests that make the expected patient-level behaviour explicit.

## Working style

- Prize legibility over cleverness.
- Use clear intermediate names for subqueries, date cutoffs, codelists, and derived concepts.
- Add short, informative comments when they help a reviewer map the code back to the user's original specification.
- Comments are most useful when they explain why a block exists or which requirement it satisfies.
- When you add tests, organize scenarios so they are easy to scan:
  `in population`, `excluded`, `boundary date`, `no matching event`, `multiple matching events`, and similar slices.

## Runbook

- Setup: `bash .codex/setup.sh`
- Generate dummy data: `uv run ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv`
- If `uv run` has cache or sandbox issues, use the installed executable directly:
  `.venv/bin/ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv`
- Preferred assurance-test file location: `analysis/test_dataset_definition.py`
- Run assurance tests directly:
  `.venv/bin/ehrql assure analysis/test_dataset_definition.py`

## Required workflow

1. Read the user's spec and the current `analysis/dataset_definition.py`.
2. Read `references/source-index.md` for the local doc map.
3. Open only the upstream docs you need from `references/upstream/`.
4. Implement the dataset definition with explicit names and readable structure.
5. Test the result.
6. Unless the change is truly trivial, add or update assurance tests as well as running dummy-data generation.

Always test. Dummy-data generation checks that the definition compiles and can produce output. Assurance tests check the exact behaviour on representative patients.

## Upstream doc map

- `references/upstream/reference-cheatsheet.md`
  Quick syntax refresher: patient vs event frames, common tables, codelists, `where`, `sort_by`, `first_for_patient`, `last_for_patient`, aggregations, date predicates, and operators.
- `references/upstream/how-to-examples.md`
  Large cookbook of query patterns across tables such as patients, addresses, registrations, clinical events, medications, APCS, and vaccinations. Best used as a pattern library rather than read end to end.
- `references/upstream/how-to-define-population.md`
  Focused guidance on `define_population()`, logical operators, required parentheses, and the common inclusion plus exclusion pattern `inclusion & ~exclusion`.
- `references/upstream/how-to-dummy-data.md`
  Explains the three dummy-data modes: auto-generated dummy data, a supplied dummy dataset file, or supplied dummy tables. Relevant whenever you need to smoke-test a dataset definition.
- `references/upstream/how-to-dummy-measures-data.md`
  Equivalent dummy-data guidance for measures definitions. Usually irrelevant unless the task shifts from datasets to measures.
- `references/upstream/reference-language.md`
  Canonical language reference for datasets, frames, series, date arithmetic, codelists, functions, measures, parameters, and permissions. Use this when semantics matter.
- `references/upstream/how-to-assign-multiple-columns.md`
  Shows when to use `dataset.add_column()` and how to build repeated columns programmatically from a mapping.
- `references/upstream/how-to-test-dataset-definition.md`
  Main guide for assurance tests. Covers the nested `test_data` structure, expected population membership, expected output columns, and how to encode one-row and many-row tables.
- `references/upstream/how-to-parameterise-ehrql.md`
  Shows how to reuse one definition with `get_parameter(...)` for dates, regions, codelists, and other user arguments.

## Testing expectations

- Minimum: run dummy-data generation after every substantive edit.
- Add assurance tests when logic includes branching, exclusions, date windows, sorted event selection, derived booleans, or any behaviour that could be disputed from reading alone.
- In assurance tests, make the patient stories obvious. A small number of well-named scenarios is better than a dense unreadable fixture.

## References

- Generated local index: `references/source-index.md`
- Upstream copies: `references/upstream/*.md`
- Generator script: `scripts/generate-skill-docs.sh`
