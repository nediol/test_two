#!/bin/bash

# цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # сброс цвета

# завершить выполнение при ошибке
set -e

echo -e "${GREEN}Stopping and disabling test-monitor.service...${NC}"
systemctl stop test-monitor.service || true
systemctl disable test-monitor.service || true

echo -e "${GREEN}Removing systemd service file...${NC}"
rm -f /etc/systemd/system/test-monitor.service

echo -e "${GREEN}Removing monitoring script...${NC}"
rm -f /usr/local/bin/test-monitor.sh

echo -e "${GREEN}Removing PID state file (if exists)...${NC}"
rm -f /var/run/test_monitor_last_pid /var/tmp/test_monitor_last_pid /tmp/test_monitor_last_pid

echo -e "${GREEN}Reloading systemd daemon...${NC}"
systemctl daemon-reexec
systemctl daemon-reload

# (опционально) удаляем лог-файл
if [[ -f /var/log/monitoring.log ]]; then
    echo -e "${GREEN}Found log file. Removing /var/log/monitoring.log...${NC}"
    rm -f /var/log/monitoring.log
fi

echo -e "${GREEN}Uninstallation completed.${NC}"

