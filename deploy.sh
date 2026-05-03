#!/bin/bash
set -e

TARGET_DIR="/home/pass1234/Desktop/DevOps/catty-reminders-app"
IMAGE_NAME="ghcr.io/vladagusakova/catty-reminders-app:latest"

COMMIT_SHA=$2

echo "Переходим в директорию $TARGET_DIR..."
cd "$TARGET_DIR"

if[ -n "$COMMIT_SHA" ] && [ "$COMMIT_SHA" != "unknown" ]; then
    echo "DEPLOY_REF=$COMMIT_SHA" > .env
fi

echo "Скачиваем новый Docker-образ..."
docker pull $IMAGE_NAME

echo "Останавливаем и удаляем старый контейнер (если есть)..."
docker rm -f catty-app-container || true

echo "Запускаем новый контейнер с пробросом файла .env..."
docker run -d -p 8181:8181 --env-file .env --name catty-app-container  --restart always $IMAGE_NAME

echo "Развертывание через Docker завершено успешно!"
