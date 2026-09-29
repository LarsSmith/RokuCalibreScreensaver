#!/usr/bin/env python3

import json
import mimetypes
import os
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import quote, unquote, urlparse

ROOT = Path("/mnt/alpha/Calibre-sync").resolve()
HOST = "0.0.0.0"
PORT = 8765


def build_catalog():
    libraries = []

    for library_dir in sorted(ROOT.iterdir(), key=lambda p: p.name.lower()):
        if not library_dir.is_dir():
            continue

        books = []

        for cover_path in library_dir.rglob("cover.jpg"):
            relative = cover_path.relative_to(ROOT)

            books.append({
                "cover": "/files/" + quote("/".join(relative.parts), safe="/")
            })

        books.sort(key=lambda item: item["cover"].lower())

        libraries.append({
            "name": library_dir.name,
            "books": books
        })

    return {
        "libraries": libraries
    }


class CoverServerHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == "/catalog.json":
            self.serve_catalog()
            return

        if parsed.path.startswith("/files/"):
            self.serve_file(parsed.path)
            return

        if parsed.path == "/":
            self.serve_index()
            return

        self.send_error(HTTPStatus.NOT_FOUND, "Not found")

    def serve_catalog(self):
        catalog = build_catalog()
        body = json.dumps(
            catalog,
            indent=2,
            ensure_ascii=False
        ).encode("utf-8")

        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(body)

    def serve_file(self, request_path):
        relative_path = unquote(request_path[len("/files/"):])

        try:
            file_path = (ROOT / relative_path).resolve()
        except Exception:
            self.send_error(HTTPStatus.BAD_REQUEST, "Invalid path")
            return

        # Prevent ../ path traversal.
        try:
            file_path.relative_to(ROOT)
        except ValueError:
            self.send_error(HTTPStatus.FORBIDDEN, "Forbidden")
            return

        if not file_path.is_file():
            self.send_error(HTTPStatus.NOT_FOUND, "File not found")
            return

        content_type, _ = mimetypes.guess_type(file_path)
        if content_type is None:
            content_type = "application/octet-stream"

        stat = file_path.stat()

        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(stat.st_size))
        self.send_header("Cache-Control", "public, max-age=3600")
        self.end_headers()

        with file_path.open("rb") as f:
            while chunk := f.read(64 * 1024):
                self.wfile.write(chunk)

    def serve_index(self):
        body = (
            "<html><body>"
            "<h1>Roku Cover Server</h1>"
            '<p><a href="/catalog.json">catalog.json</a></p>'
            "</body></html>"
        ).encode("utf-8")

        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        print(
            f"{self.client_address[0]} "
            f"{self.log_date_time_string()} "
            f"{format % args}"
        )


def main():
    if not ROOT.is_dir():
        raise SystemExit(f"Library root does not exist: {ROOT}")

    server = ThreadingHTTPServer((HOST, PORT), CoverServerHandler)

    print(f"Serving Calibre covers from: {ROOT}")
    print(f"Listening on: http://{HOST}:{PORT}")
    print(f"Catalog: http://<snowflake-ip>:{PORT}/catalog.json")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping...")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
