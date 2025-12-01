#!/bin/bash

set -euo pipefail

BRANCH_PREFIXES=("develop_" "test_")
MAX_AGE_DAYS=15                       # Максимальный возраст веток в днях
REPO_PATH="/root/testapp"


cd "$REPO_PATH" || exit 1

git fetch --all --prune

git for-each-ref --format='%(refname:short) %(committerdate:unix)' refs/heads/ | while read -r BRANCH TS; do
    case "$BRANCH" in
        main|master|develop)
            continue
            ;;
    esac

    NOW=$(date +%s)
    DIFF=$(( (NOW - TS) / 86400 ))
    echo $DIFF
done
