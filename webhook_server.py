#!/usr/bin/env python3
import tempfile
import subprocess
import json
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 8080
TARGET_BRANCH = "lab1"

class WebhookHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        html = "<html><body><h1>Webhook сервер работает! Жду POST запросов от GitHub...</h1></body></html>"
        self.wfile.write(html.encode('utf-8'))

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        try:
            payload = json.loads(body.decode('utf-8'))
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "success"}')
            
            event_type = self.headers.get('X-GitHub-Event', 'unknown')
            if event_type == 'push':
                self._handle_push_event(payload)
            elif event_type == 'ping':
                print("Получен тестовый PING от GitHub! Связь установлена.")
        except json.JSONDecodeError:
            self.send_response(400)
            self.end_headers()

    def _handle_push_event(self, payload):
        branch = payload.get('ref', '').replace('refs/heads/', '')
        clone_url = payload.get('repository', {}).get('clone_url', 'unknown')

        if branch != TARGET_BRANCH:
            print(f"Игнорируем пуш в ветку {branch}. Ждем {TARGET_BRANCH}.")
            return

        print(f"\nПУШ В ВЕТКУ {branch}! ЗАПУСКАЕМ АВТОМАТИЗАЦИЮ:")
        
        with tempfile.TemporaryDirectory() as tmpdir:
            print(f"   Скачиваем код во временную папку...")
            subprocess.run(["git", "clone", clone_url, tmpdir], check=True)
            subprocess.run(["git", "checkout", branch], cwd=tmpdir, check=True)

            print(f"   - Запуск тестов (test.sh)...")
            try:
                result = subprocess.run(["./test.sh"], cwd=tmpdir, check=True, capture_output=True, text=True)
                print(f"   ✅ Тесты пройдены!")
                
                print(f"   - Запуск деплоя на сервере (deploy.sh)...")
                subprocess.run(["./deploy.sh"], cwd=tmpdir, check=True)
            except subprocess.CalledProcessError as e:
                print(f"   ❌ ОШИБКА! Автоматизация прервана.")
                print(f"Вывод: {e.stdout}\nОшибки: {e.stderr}")

if __name__ == '__main__':
    print(f"Webhook Server запущен на порту {PORT}")
    print(f"👉 Адрес для настроек GitHub: http://webhook.gusakova.course.prafdin.ru")
    print(f"👉 Адрес вашего приложения:   http://app.gusakova.course.prafdin.ru")
    print("Ожидаю событий от GitHub...\n")
    HTTPServer(('0.0.0.0', PORT), WebhookHandler).serve_forever()
