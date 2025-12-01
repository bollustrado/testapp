#!/bin/bash

set -euo pipefail

BRANCH_PREFIXES=("develop_" "test_")
MAX_AGE_DAYS=15                       # Максимальный возраст веток в днях
REPO_PATH="."


cd "$REPO_PATH" || exit 1

git fetch --all --prune

for branch in $(git for-each-ref --format='%(refname:short) %(committerdate:unix)' refs/heads/); do
  BRANCH=$(echo $branch|awk '{print $1}')
#  echo $BRANCH
  TS=$(echo $branch|awk '{print $2}')
  echo $TS
  for prefix in "${BRANCH_PREFIXES[@]}"; do
      if [[ "$BRANCH" == "$prefix"* ]]; then
        echo "Кастомная ветка: '$prefix'"
        NOW=$(date +%s)
        echo "now $NOW"
        echo "ts $TS"
        DIFF=$(( (NOW - TS) / 86400 ))
        echo "diff $DIFF"
      fi
  done



done
