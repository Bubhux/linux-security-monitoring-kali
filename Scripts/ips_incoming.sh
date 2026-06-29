#!/bin/bash
ss -tn state established 2>/dev/null | tail -n +2 | awk '{print $4}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:' | sort | uniq -c | sort -rn | head -5 | awk '{split($2, a, ":"); printf "%-20s %s\n", a[1], a[2]}'
