#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Вспомогательная функция для вывода сообщений
print_message() {
    local type=$1
    local message=$2
    case $type in
        "error")   echo -e "${RED}Ошибка: ${message}${NC}" ;;
        "success") echo -e "${GREEN}${message}${NC}" ;;
        "info")    echo -e "${YELLOW}${message}${NC}" ;;
    esac
} 