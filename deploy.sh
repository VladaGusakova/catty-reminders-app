#!/bin/bash
set -e

TARGET_DIR="/home/pass1234/Desktop/DevOps/catty-reminders-app"

echo "Переходим в боевую директорию $TARGET_DIR..."
cd "$TARGET_DIR"

echo "Стягиваем последние изменения из ветки lab1..."
git fetch origin lab1
git reset --hard origin/lab1

echo "Записываем хэш коммита в .env..."
COMMIT_SHA=$(git rev-parse HEAD)
echo "DEPLOY_REF=$COMMIT_SHA" > "$TARGET_DIR/.env"

echo "Обновляем зависимости..."
source .venv/bin/activate
pip install -r requirements.txt

echo "Перезапускаем системную службу uvicorn..."
sudo systemctl restart catty-app

echo "Развертывание завершено успешно!"
