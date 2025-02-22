#!/bin/bash

# Подключаем утилиты
source "$(dirname "$0")/utils.sh"

# Проверка, находимся ли мы в git репозитории
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_message "error" "Не является git репозиторием"
    exit 1
fi

# Если передан аргумент ".", выполняем git add .
if [ "$1" = "." ]; then
    print_message "info" "Добавление всех изменений..."
    git add .
fi

# Проверка что был сделан git add
if git diff --cached --quiet; then
    print_message "error" "Нет staged изменений. Сначала выполните 'git add'"
    exit 1
fi

# Получаем текущую ветку
branch=$(git branch --show-current)

# Проверка, что мы НЕ находимся в master/main ветке
if [ "$branch" = "master" ] || [ "$branch" = "main" ]; then
    print_message "error" "Нельзя коммитить напрямую в ветку $branch!"
    exit 1
fi

print_message "info" -n "Внимание: Вы находитесь в ветке $branch. Продолжить? (y/n) "
read -r answer
if [[ "$answer" != "y" ]]; then
    print_message "info" "Операция отменена"
    exit 0
fi

# Запрашиваем описание изменений
print_message "info" -n "Введите описание изменений (не может быть пустым): "
read -r changes

while [ -z "$changes" ]; do
    print_message "error" "Описание не может быть пустым!"
    print_message "info" -n "Введите описание изменений: "
    read -r changes
done

# Формируем commit message в зависимости от типа ветки
if [[ $branch == hotfix* ]]; then
    commit_message="[hotfix] $changes"
else
    commit_message="[$branch] $changes"
fi

# Создаем коммит
print_message "info" "Создание коммита..."
git commit -m "$commit_message"

# Проверяем успешность коммита
if [ $? -ne 0 ]; then
    print_message "error" "Ошибка при создании коммита"
    exit 1
fi

# Пушим изменения
print_message "info" "Отправка изменений в удаленный репозиторий..."
git push --set-upstream origin "$branch"

# Проверка успешности выполнения
if [ $? -eq 0 ]; then
    print_message "success" "Изменения успешно закоммичены и отправлены в ветку $branch!"
else
    print_message "error" "Ошибка при отправке изменений. Проверьте подключение к интернету и права доступа."
    exit 1
fi
