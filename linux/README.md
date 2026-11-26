# T01-1 - Server Health Check

## Overview

A Bash script developed as part of my internship at Tecso to automate server health monitoring.

## Features

- Root disk usage monitoring
- RAM usage reporting
- One-minute system load monitoring
- Systemd service status checking
- Configurable disk usage threshold
- Error handling and exit codes

## Requirements

- Ubuntu Linux
- Bash
- Systemd
- Standard Linux utilities

## Usage

chmod +x health-check.sh
./health-check.sh systemd-journald
## Custom Disk Limit

The default disk usage threshold is 80%.

DISK_LIMIT=50 ./health-check.sh systemd-journald
## Exit Codes

| Code | Description |
|------|-------------|
| 0 | Healthy |
| 1 | Unhealthy |
| 2 | Invalid arguments or configuration |

## Sample Output - Healthy

== health check: laptop @ 2026-11-26 12:47 ==
disk / : 22% used OK
memory : 12175 MB available of 15134 MB
load (1 min) : 0.13
service systemd-journald : active OK
-- status: HEALTHY
Exit code: 0

## Sample Output - Unhealthy

== health check: laptop @ 2026-11-26 12:48 ==
disk / : 22% used FAIL (limit 0%)
memory : 12162 MB available of 15134 MB
load (1 min) : 0.55
service systemd-journald : active OK
-- status: UNHEALTHY (1 problems)
Exit code: 1

## Code Quality

The script was checked using ShellCheck with no warnings.

shellcheck health-check.sh
## Project Information

- Module: Linux
- Task: T01-1
- Language: Bash
- Internship: Tecso

