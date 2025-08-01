#!/bin/bash

# цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # сброс цвета

# завершить выполнение при любой ошибке
set -e

# проверка наличия исходных файлов
MISSING=0

if [[ ! -f ./source/test-monitor.sh ]]; then
    echo -e "${RED}Missing: ./source/test-monitor.sh${NC}"
    MISSING=1
fi

if [[ ! -f ./source/test-monitor.service ]]; then
    echo -e "${RED}Missing: ./source/test-monitor.service${NC}"
    MISSING=1
fi

if [[ "$MISSING" -eq 1 ]]; then
    echo -e "${RED}One or more required source files are missing. Aborting.${NC}"
    exit 1
fi

# сохраняем скрипт
cp ./source/test-monitor.sh /usr/local/bin/test-monitor.sh
chmod 711 /usr/local/bin/test-monitor.sh

# сохраняем systemd unit
cp ./source/test-monitor.service /etc/systemd/system/test-monitor.service
chmod 644 /etc/systemd/system/test-monitor.service

# создаем лог-файл и даем нужные права
touch /var/log/monitoring.log
chown root:root /var/log/monitoring.log
chmod 644 /var/log/monitoring.log

# перезапускаем systemd
systemctl daemon-reexec
systemctl daemon-reload

# включаем сервис мониторинга
systemctl enable --now test-monitor.service

# проверка статуса сервиса мониторинга
if systemctl is-active --quiet test-monitor.service; then
    echo -e "${GREEN}test-monitor.service is active and running.${NC}"
else
    echo -e "${RED}test-monitor.service is NOT active! Check for errors.${NC}"
fi
