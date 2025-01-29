# common-scripts

Коллекция полезных bash скриптов для повседневного использования.

## Установка

1. Клонируйте репозиторий:

```bash
git clone git@github.com:CallMeOneka/common-scripts.git
cd common-scripts
```

2. Добавьте скрипты в ваш `.zshrc`:

Откройте файл `.zshrc` в любом текстовом редакторе:
```bash
nano ~/.zshrc
# или
vim ~/.zshrc
```

3. Добавьте следующие строки в конец файла:
```bash
# Custom scripts
export PATH="$PATH:$HOME/path/to/common-scripts"

# Алиасы для часто используемых скриптов
alias cs='cd ~/path/to/common-scripts'
```

4. Сделайте скрипты исполняемыми:
```bash
chmod +x ~/path/to/common-scripts/*
```

5. Примените изменения:
```bash
source ~/.zshrc
```

## Использование

После установки вы можете использовать скрипты напрямую из командной строки:

```bash
script-name [аргументы]
```

## Добавление новых скриптов

1. Создайте новый скрипт в директории:
```bash
touch new-script.sh
chmod +x new-script.sh
```

2. Добавьте шебанг и код:
```bash
#!/bin/bash
# Ваш код здесь
```

## Примечания

- Убедитесь, что заменили `path/to/common-scripts` на актуальный путь к директории со скриптами
- Рекомендуется добавлять описание каждого скрипта в этот README файл
- Не забудьте добавить шебанг (`#!/bin/bash`) в начало каждого скрипта

## Лицензия

MIT
