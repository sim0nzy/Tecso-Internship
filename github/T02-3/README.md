# T02-3: First GitHub Actions

## Overview
Automated CI for Bash scripts using GitHub Actions.

## Workflow
- Trigger: Push and Pull Request targeting main.
- Runner: ubuntu-latest.
- ShellCheck: Validates all Bash scripts.
- Smoke: Verifies health-check.sh returns exit code 2 without arguments.

## Test Results
- Run #1: Failed intentionally with SC2086.
- Run #2: Passed successfully after fixing the warning.

## Bonus Features
- Path filtering for linux/ directory.
- Workflow status badge in the main README.

