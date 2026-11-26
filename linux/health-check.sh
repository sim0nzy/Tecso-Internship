#!/usr/bin/env bash

set -euo pipefail

# Validate arguments
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <service>" >&2
    exit 2
fi

# Initialize variables
service="$1"
disk_limit="${DISK_LIMIT:-80}"
problems=0

# Validate disk limit
if [[ ! "$disk_limit" =~ ^(0|[1-9][0-9]?|100)$ ]]; then
    echo "Error: DISK_LIMIT must be between 0 and 100." >&2
    exit 2
fi

# Collect system information
disk_used=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

read -r mem_total mem_available < <(
    free -m | awk '$1 == "Mem:" {print $2, $7}'
)

read -r load _ < /proc/loadavg

# Print report header
echo "== health check: $(hostname) @ $(date '+%F %H:%M') =="

# Check disk usage
if [[ "$disk_used" -gt "$disk_limit" ]]; then
    printf "disk / : %s%% used FAIL (limit %s%%)\n" "$disk_used" "$disk_limit"
    problems=$((problems + 1))
else
    printf "disk / : %s%% used OK\n" "$disk_used"
fi

# Print memory and CPU load
echo "memory : $mem_available MB available of $mem_total MB"
echo "load (1 min) : $load"

# Check service status
if systemctl is-active --quiet -- "$service"; then
    echo "service $service : active OK"
else
    echo "service $service : not active FAIL"
    problems=$((problems + 1))
fi

# Print final status
if [[ "$problems" -eq 0 ]]; then
    echo "-- status: HEALTHY"
    exit 0
else
    echo "-- status: UNHEALTHY ($problems problems)"
    exit 1
fi
