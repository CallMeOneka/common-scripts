#!/bin/bash

set -e # Прерывать выполнение при любой ошибке

# Подключаем утилиты
source "$(dirname "$0")/utils.sh"

# Регулярное выражение для проверки номера задачи
TASK_NUMBER_INNER_REGEX='[a-zA-Z0-9\-]+'
TASK_NUMBER_REGEX="^${TASK_NUMBER_INNER_REGEX}$"

# Проверка, что мы находимся в git репозитории
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  print_message "error" "Скрипт должен выполняться в git репозитории!"
  exit 1
fi

# Проверка наличия незакоммиченных изменений
# if ! git diff-index --quiet HEAD --; then
#   print_message "error" "В репозитории есть незакоммиченные изменения!"
#   exit 1
# fi

# Проверка, что мы не в ветке master
if [[ $(git branch --show-current) == "master" ]]; then
  print_message "error" "Нельзя выпускать версию из ветки master!"
  exit 1
fi

# Получаем текущую версию
CURRENT_VERSION=$(npm pkg get version | tr -d '"')

# Функция для извлечения номера задачи из имени ветки
get_default_task_number() {
  local branch_name=$(git branch --show-current)
  local task_number

  # Пытаемся найти числа в имени ветки
  if [[ $branch_name =~ ([0-9]+) ]]; then
    task_number="${BASH_REMATCH[1]}"
  else
    task_number="$branch_name"
  fi

  echo "$task_number"
}

# Если версия уже в формате X.Y.Z-dev.<TASK>.<ITERATION>
if [[ $CURRENT_VERSION =~ ^([0-9]+\.[0-9]+\.[0-9]+)-dev\.(${TASK_NUMBER_INNER_REGEX})\.([0-9]+)$ ]]; then
  BASE_VERSION=${BASH_REMATCH[1]}
  TASK_NUMBER=${BASH_REMATCH[2]}
  ITERATION=$((${BASH_REMATCH[3]} + 1))

  # Проверяем, совпадает ли task_number с текущей веткой
  BRANCH_NAME=$(get_default_task_number)
  if [[ $TASK_NUMBER != $BRANCH_NAME ]]; then
    print_message "info" "Текущий номер задачи ($TASK_NUMBER) отличается от имени ветки ($BRANCH_NAME)"
    print_message "info" -n "Вы можете изменить номер задачи по желанию (по умолчанию: $TASK_NUMBER): "
    read -r NEW_TASK_NUMBER
    if [[ -n $NEW_TASK_NUMBER ]]; then
      # Проверяем, что новый номер задачи содержит только буквы, цифры и тире
      while ! [[ $NEW_TASK_NUMBER =~ $TASK_NUMBER_REGEX ]]; do
        print_message "error" "Ошибка: Номер задачи может содержать только буквы, цифры и тире!"
        print_message "info" -n "Введите новый номер задачи (по умолчанию: $TASK_NUMBER): "
        read -r NEW_TASK_NUMBER
      done
      TASK_NUMBER=$NEW_TASK_NUMBER
      ITERATION=0
    fi
  fi

  NEW_VERSION="${BASE_VERSION}-dev.${TASK_NUMBER}.${ITERATION}"

# Если версия в формате X.Y.Z
elif [[ $CURRENT_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  print_message "info" "Создаем новую dev версию по шаблону X.Y.Z-dev.<TASK>.<ITERATION>"
  # Автоматически увеличиваем версию на 1
  IFS='.' read -r -a VERSION_PARTS <<<"$CURRENT_VERSION"
  NEW_BASE_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.$((VERSION_PARTS[2] + 1))"

  # Предлагаем пользователю ввести новую версию или использовать автоматическую
  print_message "info" -n "Введите новую версию (по умолчанию: $NEW_BASE_VERSION): "
  read -r USER_INPUT
  NEW_BASE_VERSION=${USER_INPUT:-$NEW_BASE_VERSION}

  # Проверяем формат новой версии
  while ! [[ $NEW_BASE_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    print_message "info" -n "Неверный формат. Введите версию в формате X.Y.Z: "
    read -r NEW_BASE_VERSION
  done

  # Получаем номер задачи из имени ветки, если не введен вручную
  BRANCH_NAME=$(get_default_task_number)
  print_message "info" -n "Введите номер задачи (по умолчанию: $BRANCH_NAME): "
  read -r TASK_NUMBER
  TASK_NUMBER=${TASK_NUMBER:-$BRANCH_NAME}

  # Проверяем, что номер задачи содержит только буквы, цифры и тире
  while ! [[ $TASK_NUMBER =~ $TASK_NUMBER_REGEX ]]; do
    print_message "error" "Ошибка: Номер задачи может содержать только буквы, цифры и тире!"
    print_message "info" -n "Введите номер задачи (по умолчанию: $BRANCH_NAME): "
    read -r TASK_NUMBER
    TASK_NUMBER=${TASK_NUMBER:-$BRANCH_NAME}
  done

  NEW_VERSION="${NEW_BASE_VERSION}-dev.${TASK_NUMBER}.0"

# Если версия в неподдерживаемом формате
else
  print_message "error" "Текущая версия $CURRENT_VERSION в неподдерживаемом формате!"
  print_message "info" -n "Введите новую версию в формате X.Y.Z: "
  read -r NEW_BASE_VERSION

  # Проверяем формат новой версии
  while ! [[ $NEW_BASE_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    print_message "error" "Неверный формат версии!"
    print_message "info" -n "Введите версию в формате X.Y.Z: "
    read -r NEW_BASE_VERSION
  done

  # Получаем номер задачи из имени ветки, если не введен вручную
  BRANCH_NAME=$(get_default_task_number)
  print_message "info" -n "Введите номер задачи (по умолчанию: $BRANCH_NAME): "
  read -r TASK_NUMBER
  TASK_NUMBER=${TASK_NUMBER:-$BRANCH_NAME}

  # Проверяем, что номер задачи содержит только буквы, цифры и тире
  while ! [[ $TASK_NUMBER =~ $TASK_NUMBER_REGEX ]]; do
    print_message "error" "Ошибка: Номер задачи может содержать только буквы, цифры и тире!"
    print_message "info" -n "Введите номер задачи (по умолчанию: $BRANCH_NAME): "
    read -r TASK_NUMBER
    TASK_NUMBER=${TASK_NUMBER:-$BRANCH_NAME}
  done

  NEW_VERSION="${NEW_BASE_VERSION}-dev.${TASK_NUMBER}.0"
fi

# Выполняем команды
# npm version $NEW_VERSION
# git push origin $(git branch --show-current)
# git push --tags

echo "Новая версия успешно выпущена: $NEW_VERSION"
