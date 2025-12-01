#!/bin/bash

set -euo pipefail

BRANCH_PREFIXES=("develop_" "test_")
MAX_AGE_DAYS=15                       # Максимальный возраст веток в днях
REPO_PATH="."

stop_pm2_process() {
    local branch_name="$1"
#    local app_name="${PM2_APP_PREFIX}${branch_name//\//-}"

    echo "Останавливаю pm2 процесс: $BRANCH"

    if pm2 describe "$BRANCH" &> /dev/null; then
        pm2 stop "$BRANCH"
        pm2 delete "$BRANCH"
        echo "Pm2 процесс $BRANCH остановлен и удален"
        return 0
    else
        echo "Pm2 процесс $BRANCH не найден"
        return 1
    fi
}

cd "$REPO_PATH" || exit 1

git fetch --all --prune

git for-each-ref --format='%(refname:short) %(committerdate:unix)' refs/heads/|while read BRANCH TS; do
#  echo $TS
  for prefix in "${BRANCH_PREFIXES[@]}"; do
      if [[ "$BRANCH" == "$prefix"* ]]; then
        echo "Кастомная ветка: '$prefix'"
        NOW=$(date +%s)
#        echo "now $NOW"
#        echo "ts $TS"
        DIFF=$(( (NOW - TS) / 86400 ))
        echo "diff $DIFF"
        if [ "$DIFF" -lt "$MAX_AGE_DAYS" ]; then
          PORT=$(cat "$REPO_PATH"/*_ports|grep $BRANCH|awk -F' : ' '{print $2}')
#          echo "port: $PORT"
          PID=$(pm2 jlist | jq '.[] | select(.name=="test-server") | .pid')
#          echo $PID
          stop_pm2_process "$BRANCH"
          if lsof -i ":$PORT" >/dev/null 2>&1; then
            PID=$(lsof -t -i ":$PORT")
            echo "Освобождение порта $PORT, убийство PID $PID"
            kill -9 "$PID"
          fi
          sed -i "s/^$BRANCH : .*/$BRANCH : none/" "$REPO_PATH"/*_ports
        fi
      fi
  done



done
