#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

# Check JSON option
json_mode=false

if [[ "${1:-}" == "--json" ]]; then
    json_mode=true
    shift
fi

# Validate arguments
if [[ $# -eq 0 ]]; then
    printf 'Usage: %s [--json] <service> [service ...]\n' "$0" >&2
    exit 2
fi

disk_limit="${DISK_LIMIT:-80}"
problems=0

# Validate disk limit
if [[ ! "$disk_limit" =~ ^(0|[1-9][0-9]?|100)$ ]]; then
    echo "Error: DISK_LIMIT must be between 0 and 100." >&2
    exit 2
fi

# Collect system information
host=$(hostname)
timestamp=$(date '+%F %H:%M')

disk_used=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

read -r mem_total mem_available < <(
    free -m | awk '$1 == "Mem:" {print $2, $7}'
)

read -r load _ < /proc/loadavg

# Check disk usage
disk_status=OK

if [[ "$disk_used" -gt "$disk_limit" ]]; then
    disk_status=FAIL
    problems=$((problems + 1))
fi

# Check multiple services
services=("$@")
states=()
results=()

for service in "${services[@]}"; do
    if systemctl is-active --quiet -- "$service"; then
        states+=(active)
        results+=(OK)
    else
        states+=("not active")
        results+=(FAIL)
        problems=$((problems + 1))
    fi
done

# Determine final status
status=HEALTHY

if [[ "$problems" -gt 0 ]]; then
    status=UNHEALTHY
fi

# Escape JSON strings
json_string() {
    local value="$1" char code i
    printf '"'

    for ((i=0; i<${#value}; i++)); do
        char="${value:i:1}"

        case "$char" in
            '"'|\\)
                printf '\\%s' "$char"
                ;;
            [[:cntrl:]])
                printf -v code '%d' "'$char"
                printf '\\u%04x' "$code"
                ;;
            *)
                printf '%s' "$char"
                ;;
        esac
    done

    printf '"'
}

# Color output only in terminal
print_result() {
    if [[ -t 1 ]]; then
        if [[ "$1" == OK ]]; then
            printf '\033[32m%s\033[0m' "$1"
        else
            printf '\033[31m%s\033[0m' "$1"
        fi
    else
        printf '%s' "$1"
    fi
}

# JSON output
if [[ "$json_mode" == true ]]; then
    printf '{"hostname":'
    json_string "$host"

    printf ',"timestamp":'
    json_string "$timestamp"

    printf ',"disk":{"used_percent":%s,"limit_percent":%s,"status":"%s"}' \
        "$disk_used" "$disk_limit" "$disk_status"

    printf ',"memory":{"available_mb":%s,"total_mb":%s}' \
        "$mem_available" "$mem_total"

    printf ',"load_1min":%s,"services":[' "$load"

    for i in "${!services[@]}"; do
        if [[ "$i" -gt 0 ]]; then
            printf ','
        fi

        printf '{"name":'
        json_string "${services[i]}"

        printf ',"state":"%s","status":"%s"}' \
            "${states[i]}" "${results[i]}"
    done

    printf '],"status":"%s","problems":%s}\n' \
        "$status" "$problems"

# Standard output
else
    printf '== health check: %s @ %s ==\n' \
        "$host" "$timestamp"

    printf 'disk / : %s%% used ' "$disk_used"
    print_result "$disk_status"

    if [[ "$disk_status" == FAIL ]]; then
        printf ' (limit %s%%)' "$disk_limit"
    fi

    printf '\n'

    printf 'memory : %s MB available of %s MB\n' \
        "$mem_available" "$mem_total"

    printf 'load (1 min) : %s\n' "$load"

    for i in "${!services[@]}"; do
        printf 'service %s : %s ' \
            "${services[i]}" "${states[i]}"

        print_result "${results[i]}"
        printf '\n'
    done

    if [[ "$status" == HEALTHY ]]; then
        printf '%s\n' '-- status: HEALTHY'
    else
        printf '%s (%s problems)\n' \
            '-- status: UNHEALTHY' "$problems"
    fi
fi

# Exit codes
if [[ "$problems" -eq 0 ]]; then
    exit 0
fi

exit 1

