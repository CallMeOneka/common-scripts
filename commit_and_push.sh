#!/bin/bash

# Подключаем утилиты
source "$(dirname "$0")/utils.sh"

# Проверка, находимся ли мы в git репозитории
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_message "error" "Не является git репозиторием"
    exit 1
fi

# Проверка наличия изменений для коммита
if [ -z "$(git status --porcelain)" ]; then
    print_message "info" "Нет изменений для коммита"
    exit 0
fi

# Получаем текущую ветку
branch=$(git branch --show-current)

# Проверка, что мы не находимся в master/main ветке
if [[ "$branch" == "master" || "$branch" == "main" ]]; then
    print_message "info" "Внимание: Вы находитесь в ветке $branch. Продолжить? (y/n)"
    read -r answer
    if [[ "$answer" != "y" ]]; then
        print_message "info" "Операция отменена"
        exit 0
    fi
fi

# Запрашиваем описание изменений
while true; do
    print_message "info" "Введите описание изменений (не может быть пустым):"
    read -r changes
    if [ -n "$changes" ]; then
        break
    fi
    print_message "error" "Описание не может быть пустым. Попробуйте снова."
done

# Формируем commit message в зависимости от типа ветки
if [[ $branch == hotfix* ]]; then
    commit_message="[hotfix] $changes"
else
    commit_message="[$branch] $changes"
fi

# Создаем коммит
print_message "info" "Создание коммита..."
git add .
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
