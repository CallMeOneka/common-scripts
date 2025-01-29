#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Вспомогательная функция для вывода сообщений
print_message() {
    local type=$1
    local message
    local echo_flags="-e"

    if [[ "$2" == "-n" ]]; then
        echo_flags+="n"
        message=$3
    else
        message=$2
    fi

    case $type in
    "error") echo $echo_flags "${RED}Ошибка: ${message}${NC}" ;;
    "success") echo $echo_flags "${GREEN}${message}${NC}" ;;
    "info") echo $echo_flags "${YELLOW}${message}${NC}" ;;
    esac
}
