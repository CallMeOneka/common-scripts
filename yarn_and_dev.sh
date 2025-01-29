#!/bin/bash

# Установка зависимостей
echo "Запуск yarn для установки зависимостей..."
yarn

# Проверка успешности выполнения команды
if [ $? -eq 0 ]; then
    echo "Зависимости успешно установлены!"
    
    # Запуск dev-сервера
    echo "Запуск yarn dev..."
    yarn dev
else
    echo "Ошибка при установке зависимостей. Проверьте консоль для получения дополнительной информации."
    exit 1
fi
