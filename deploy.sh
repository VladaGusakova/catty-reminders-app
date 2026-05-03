#!/bin/bash
set -e

TARGET_DIR="/home/pass1234/Desktop/DevOps/catty-reminders-app"
COMMIT_SHA=$1

if [ -z "$COMMIT_SHA" ] || [ "$COMMIT_SHA" == "unknown" ]; then
    echo "Ошибка: COMMIT_SHA не передан!"
    exit 1
fi

IMAGE_NAME="ghcr.io/vladagusakova/catty-reminders-app:${COMMIT_SHA}"

echo "Переходим в директорию $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo "Скачиваем новый Docker-образ по хэшу: $IMAGE_NAME"
docker pull $IMAGE_NAME

echo "Останавливаем и удаляем старый контейнер (если есть)..."
docker stop catty-app-container || true
docker rm -f catty-app-container || true

echo "Запускаем новый контейнер с прямой передачей переменной..."
docker run -d --name catty-app-container --restart always -p 8181:8181 -e DEPLOY_REF="$COMMIT_SHA" $IMAGE_NAME

echo "Развертывание через Docker завершено успешно!"
