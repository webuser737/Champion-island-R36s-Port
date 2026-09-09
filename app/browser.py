import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.environ["QTWEBENGINE_RESOURCES_PATH"] = os.path.join(BASE_DIR, "resources")
os.environ["QTWEBENGINE_LOCALES_PATH"] = os.path.join(BASE_DIR, "locales")
os.environ["QTWEBENGINEPROCESS_PATH"] = os.path.join(BASE_DIR, "QtWebEngineProcess")

import sys
import os
import re
import threading
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

# ---------- WebEngine environment ----------
BASE = os.path.dirname(os.path.abspath(__file__))
BUNDLE = os.path.dirname(BASE)

os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
os.environ.pop("QTWEBENGINE_REMOTE_DEBUGGING", None)

os.environ["QT_QPA_PLATFORM"] = "eglfs"

os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = (
    "--no-sandbox "
    "--disable-gpu-sandbox "
    "--disable-dev-shm-usage "
    "--disable-software-rasterizer "
    "--ignore-gpu-blocklist "
    "--use-gl=egl "
    "--enable-gpu-compositing "
    "--enable-gpu-rasterization "
    "--enable-accelerated-2d-canvas "
    "--enable-native-gpu-memory-buffers "
    "--enable-zero-copy"
)

os.environ["QTWEBENGINE_RESOURCES_PATH"] = os.path.join(
    BUNDLE, "resources"
)

os.environ["QTWEBENGINE_LOCALES_PATH"] = os.path.join(
    BUNDLE, "locales"
)

os.environ["QTWEBENGINEPROCESS_PATH"] = os.path.join(
    BUNDLE, "QtWebEngineProcess"
)

# Use ArkOS's Qt libraries plus our missing WebEngine libraries.
system_lib = "/usr/lib/aarch64-linux-gnu"
bundle_lib = os.path.join(BUNDLE, "lib")

existing = os.environ.get("LD_LIBRARY_PATH", "")
os.environ["LD_LIBRARY_PATH"] = existing + ":" + bundle_lib + ":" + system_lib if existing else bundle_lib + ":" + system_lib

# ---------- Qt imports ----------
from PyQt5.QtCore import QCoreApplication, QUrl, Qt, QTimer
QCoreApplication.setAttribute(Qt.AA_ShareOpenGLContexts)
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5.QtWebEngineWidgets import (
    QWebEngineView,
    QWebEnginePage,
    QWebEngineProfile,
    QWebEngineScript
)

# ---------- Local HTTP server ----------
GAME_DIR = os.path.join(
    os.path.dirname(BASE),
    "game"
)

PORT = 8765


class QuietHandler(SimpleHTTPRequestHandler):

    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path.split("?", 1)[0] == "/__exit__":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK")
            print("START+SELECT EXIT REQUESTED", flush=True)

            def quit_app():
                os._exit(0)

            threading.Timer(0.05, quit_app).start()
            return

        return SimpleHTTPRequestHandler.do_GET(self)



def start_server():
    global server
    os.chdir(GAME_DIR)

    server = ThreadingHTTPServer(
        ("127.0.0.1", PORT),
        QuietHandler
    )

    print(
        "Champion Island server running at "
        f"http://127.0.0.1:{PORT}/",
        flush=True
    )

    server.serve_forever()


server_thread = threading.Thread(
    target=start_server,
    daemon=True
)

server_thread.start()

# ---------- Application ----------
print("=== QT GPU PRECHECK ===", flush=True)
try:
    from PyQt5.QtGui import QOpenGLContext
    print("QOpenGLContext available:", QOpenGLContext is not None, flush=True)
except Exception as e:
    print("QOpenGLContext import failed:", repr(e), flush=True)

app = QApplication(sys.argv)

try:
    ctx = QOpenGLContext()
    print("QOpenGLContext created:", ctx.isValid(), flush=True)
except Exception as e:
    print("QOpenGLContext creation failed:", repr(e), flush=True)

profile = QWebEngineProfile.defaultProfile()

storage_path = os.path.join(
    BUNDLE,
    "storage"
)

os.makedirs(storage_path, exist_ok=True)

profile.setPersistentStoragePath(storage_path)
profile.setPersistentCookiesPolicy(
    QWebEngineProfile.ForcePersistentCookies
)

# ---------- Browser ----------
window = QMainWindow()

view = QWebEngineView()

page = QWebEnginePage(
    profile,
    view
)

view.setPage(page)

view.setUrl(
    QUrl(
        f"http://127.0.0.1:{PORT}/index.html"
    )
)

window.setCentralWidget(view)

window.showFullScreen()

view.setFocus()

print(
    "Starting Champion Island browser...",
    flush=True
)

sys.exit(app.exec_())
