#!/bin/bash

# Проверка, что мы в ветке master
if [[ $(git branch --show-current) != "master" ]]; then
  echo "Ошибка: Этот скрипт должен выполняться только в ветке master!"
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
  IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}
  DEFAULT_NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
else
  echo "Ошибка: Неизвестный формат версии: $CURRENT_VERSION"
  exit 1
fi

# Запрашиваем новую версию
read -p "Текущая версия: $CURRENT_VERSION. Введите новую версию (X.Y.Z) или нажмите Enter для $DEFAULT_NEW_VERSION: " NEW_VERSION

# Если пользователь не ввел версию, используем версию по умолчанию
if [[ -z "$NEW_VERSION" ]]; then
  NEW_VERSION=$DEFAULT_NEW_VERSION
fi

# Проверяем формат новой версии (должен быть X.Y.Z)
while ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
  read -p "Неверный формат. Введите версию в формате X.Y.Z: " NEW_VERSION
done

# Выполняем команды
git pull
npm version $NEW_VERSION
git push origin master
git push --tags

echo "Новая версия успешно выпущена: $NEW_VERSION"