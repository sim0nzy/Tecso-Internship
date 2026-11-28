#!/usr/bin/env bash

LOG="${1:-}"

if [[ ! -f "$LOG" || ! -r "$LOG" ]]; then
    echo "Error: Please provide a readable log file." >&2
    exit 1
fi

echo "# Nginx Log Report"
echo

echo "## 1. Total Requests"
awk 'END {print NR}' "$LOG"

echo
echo "## 2. Top 5 IP Addresses"
echo "| Count | IP Address |"
echo "| --- | --- |"
awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -n 5 | awk '{printf "| %s | %s |\n", $1, $2}'

echo
echo "## 3. HTTP Status Codes"
echo "| Count | Status Code |"
echo "| --- | --- |"
awk '{print $9}' "$LOG" | sort | uniq -c | sort -rn | awk '{printf "| %s | %s |\n", $1, $2}'

echo
echo "## 4. Server Error Paths (5XX)"
echo "| Count | Path |"
echo "| --- | --- |"
awk '$9 ~ /^5[0-9][0-9]$/ {print $7}' "$LOG" | sort | uniq -c | sort -rn | awk '{printf "| %s | %s |\n", $1, $2}'

echo
echo "## 5. Peak Traffic Hour"
echo "| Count | Hour |"
echo "| --- | --- |"
awk '{split($4,t,":"); print t[2]}' "$LOG" | sort | uniq -c | sort -rn | head -n 1 | awk '{printf "| %s | %s:00 |\n", $1, $2}'

echo
echo "## 6. Failed Requests"
awk '$9 >= 400 {failed++} END {printf "%.1f%%\n", NR ? failed*100/NR : 0}' "$LOG"

echo
echo "## 7. Suspicious IP Addresses"
echo "| Failed Logins | IP Address |"
echo "| --- | --- |"
awk '$9 == 401 {print $1}' "$LOG" | sort | uniq -c | sort -rn | awk '$1 > 3 {printf "| %s | %s |\n", $1, $2}'

echo $HOME
