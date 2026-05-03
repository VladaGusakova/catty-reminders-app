#!/bin/bash
set -e

TARGET_DIR="/home/pass1234/Desktop/DevOps/catty-reminders-app"
IMAGE_NAME="ghcr.io/vladagusakova/catty-reminders-app:latest"

echo "Переходим в директорию $TARGET_DIR..."
cd "$TARGET_DIR"

echo "Скачиваем новый Docker-образ..."
docker pull $IMAGE_NAME

echo "Останавливаем и удаляем старый контейнер..."
docker rm -f catty-app-container || true

echo "Запускаем новый контейнер..."
docker run -d -p 8181:8181 --name catty-app-container --restart always $IMAGE_NAME

echo "Развертывание завершено успешно!"
