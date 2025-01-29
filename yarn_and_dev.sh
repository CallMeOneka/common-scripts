#!/bin/bash

# Подключаем утилиты
source "$(dirname "$0")/utils.sh"

# Установка зависимостей
print_message "info" "Запуск yarn для установки зависимостей..."
yarn

# Проверка успешности выполнения команды
if [ $? -eq 0 ]; then
    print_message "success" "Зависимости успешно установлены!"
    
    # Запуск dev-сервера
    print_message "info" "Запуск yarn dev..."
    yarn dev
else
    print_message "error" "Ошибка при установке зависимостей. Проверьте консоль для получения дополнительной информации."
    exit 1
fi
