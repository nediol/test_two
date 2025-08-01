 #!/bin/bash

PROCESS_NAME="test" # имя процесса, за которым будем смотреть
API_URL="https://test.com/monitoring/test/api" # адрес сервера мониторинга
STATE_FILE="/var/run/test_monitor.state" # файл состояния
LOG_FILE="/var/log/monitoring.log" # файл лога
SLEEP_INTERVAL=60 # # частота опроса (раз в 60 секунд)

while true; do
    current_pid=$(pgrep -x "$PROCESS_NAME")

    if [[ -f "$STATE_FILE" ]]; then
        last_state=$(<"$STATE_FILE")
    else
        last_state=""
    fi

    if [[ -n "$current_pid" ]]; then
        current_state="running:$current_pid"
    else
        current_state="stopped"
    fi

    if [[ "$last_state" =~ ^running: ]] && [[ "$current_state" =~ ^running: ]] && \
       [[ "$current_state" != "$last_state" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Process '$PROCESS_NAME' restarted. New PID: ${current_state#*:}" >> "$LOG_FILE"
    fi

    if [[ -n "$current_pid" ]]; then
        if ! curl -s -o /dev/null --connect-timeout 5 --max-time 10 -k -X GET "$API_URL"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitoring server not reachable at $API_URL" >> "$LOG_FILE"
        fi
    fi

    if [[ -n "$current_pid" ]]; then
        echo "$current_state" > "$STATE_FILE"
    fi

    sleep "$SLEEP_INTERVAL"
done
