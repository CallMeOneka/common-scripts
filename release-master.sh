#!/bin/bash

set -e # Прерывать выполнение при любой ошибке

# Подключаем утилиты
source "$(dirname "$0")/utils.sh"

# Проверка, что мы находимся в git репозитории
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  print_message "error" "Скрипт должен выполняться в git репозитории!"
  exit 1
fi

# Проверка наличия незакоммиченных изменений
if ! git diff-index --quiet HEAD --; then
  print_message "error" "В репозитории есть незакоммиченные изменения!"
  exit 1
fi

# Проверка, что мы в ветке master
if [[ $(git branch --show-current) != "master" ]]; then
  print_message "error" "Этот скрипт должен выполняться только в ветке master!"
  exit 1
fi

# Получаем текущую версию
CURRENT_VERSION=$(npm pkg get version | tr -d '"')

# Проверяем, является ли версия формата <YOUR_VERSION>-dev.<YOUR_TASK_NUMBER>.<iteration>
if [[ $CURRENT_VERSION =~ ^([0-9]+\.[0-9]+\.[0-9]+)-dev\..+\.[0-9]+$ ]]; then
  # Если да, предлагаем YOUR_VERSION по умолчанию
  DEFAULT_NEW_VERSION=${BASH_REMATCH[1]}
elif [[ $CURRENT_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # Если версия в формате X.Y.Z, увеличиваем патч-версию на 1
  IFS='.' read -r -a VERSION_PARTS <<<"$CURRENT_VERSION"
  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}
  DEFAULT_NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
else
  echo "Ошибка: Неизвестный формат версии: $CURRENT_VERSION"
  exit 1
fi

# Запрашиваем новую версию
print_message "info" -n "Введите новую версию (по умолчанию: $DEFAULT_NEW_VERSION): "
read -r NEW_VERSION
NEW_VERSION=${NEW_VERSION:-$DEFAULT_NEW_VERSION}

# Проверяем формат новой версии (должен быть X.Y.Z)
while ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
  print_message "error" -n "Неверный формат. Введите версию в формате X.Y.Z: "
  read -r NEW_VERSION
done

# Выполняем команды
# git pull
# npm version $NEW_VERSION
# git push origin master
# git push --tags

echo "Новая версия успешно выпущена: $NEW_VERSION"
