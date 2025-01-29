#!/bin/bash

# Подключаем утилиты
source "$(dirname "$0")/utils.sh"

# Функция для проверки наличия файла
check_file() {
    if [ ! -f "$1" ]; then
        print_message "error" "Файл $1 не найден"
        exit 1
    fi
}

# Путь к файлу .zshrc
ZSHRC="$HOME/.zshrc"
if [ ! -f "$ZSHRC" ]; then
    print_message "info" "Файл .zshrc не найден. Создаем новый..."
    touch "$ZSHRC"
fi

# Получаем абсолютный путь к директории скриптов
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Проверяем наличие файла aliases.sh
check_file "$SCRIPT_DIR/aliases.sh"

# Делаем все скрипты исполняемыми
print_message "info" "Делаем скрипты исполняемыми..."
chmod +x "$SCRIPT_DIR"/*.sh

# Строка для добавления в .zshrc
INCLUDE_LINE="source $SCRIPT_DIR/aliases.sh"

# Проверяем, есть ли уже эта строка в .zshrc
if ! grep -q "^$INCLUDE_LINE" "$ZSHRC"; then
    print_message "info" "Добавляем алиасы в .zshrc..."
    
    # Добавляем пустую строку, если файл не пустой и не заканчивается на новую строку
    if [ -s "$ZSHRC" ] && [ "$(tail -c1 "$ZSHRC")" != "" ]; then
        echo "" >> "$ZSHRC"
    fi
    
    # Добавляем блок с алиасами
    cat << EOF >> "$ZSHRC"
# Подключение пользовательских алиасов
$INCLUDE_LINE
EOF
    
    print_message "success" "✓ Алиасы успешно подключены к .zshrc"
else
    print_message "info" "✓ Алиасы уже подключены к .zshrc" "$YELLOW"
fi

# Выводим список доступных команд
print_message "info" "\nДоступные команды после установки:"
echo -e "${YELLOW}release:master${NC} - Создание релиза из ветки master"
echo -e "${YELLOW}release:dev${NC} - Создание dev-релиза из любой ветки"
echo -e "${YELLOW}gcp${NC} - Быстрый коммит и пуш изменений"
echo -e "${YELLOW}yd${NC} - Установка зависимостей и запуск dev-сервера"

print_message "\nЧтобы применить изменения, выполните команду:" "$YELLOW"
echo -e "${GREEN}source ~/.zshrc${NC}" 