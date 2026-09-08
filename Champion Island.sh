#!/bin/bash

GAMEDIR="/roms/ports/championisland"
LOG="$GAMEDIR/launcher.log"

exec > >(tee "$LOG") 2>&1

echo "=== CHAMPION ISLAND START ==="
date

echo "=== SYSTEM ==="
uname -a
id

echo "=== PYTHON ==="
which python3
python3 --version

echo "=== FILES ==="
ls -lh "$GAMEDIR/QtWebEngineProcess"
ls -lh "$GAMEDIR/lib/libQt5WebEngineCore.so.5.12.4"
ls -lh "$GAMEDIR/sip.cpython-37m-aarch64-linux-gnu.so"
ls -lh "$GAMEDIR/PyQt5/QtCore.cpython-37m-aarch64-linux-gnu.so"
ls -lh "$GAMEDIR/PyQt5/QtWebEngineWidgets.cpython-37m-aarch64-linux-gnu.so"

echo "=== PYTHONPATH ==="
export PYTHONPATH="$GAMEDIR:$GAMEDIR/app:$PYTHONPATH"
echo "$PYTHONPATH"

echo "=== LIBRARY PATH ==="
export LD_LIBRARY_PATH="/usr/local/lib/aarch64-linux-gnu:$GAMEDIR/lib:/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH"
echo "$LD_LIBRARY_PATH"

echo "=== QT ENVIRONMENT ==="
export TERM=linux
export XDG_RUNTIME_DIR="/tmp/xdg-runtime-$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
export QT_QPA_PLATFORM=eglfs

export QTWEBENGINE_DISABLE_SANDBOX=1
export QTWEBENGINE_REMOTE_DEBUGGING=9222

export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage --enable-gpu-rasterization --enable-native-gpu-memory-buffers --ignore-gpu-blocklist"

export QTWEBENGINE_RESOURCES_PATH="$GAMEDIR/resources"
export QTWEBENGINE_LOCALES_PATH="$GAMEDIR/locales"
export QTWEBENGINEPROCESS_PATH="$GAMEDIR/QtWebEngineProcess"

mkdir -p /home/ark/.browser.py
ln -sf "$GAMEDIR/resources/qtwebengine_resources.pak" /home/ark/.browser.py/qtwebengine_resources.pak
ln -sf "$GAMEDIR/resources/qtwebengine_resources_100p.pak" /home/ark/.browser.py/qtwebengine_resources_100p.pak
ln -sf "$GAMEDIR/resources/qtwebengine_resources_200p.pak" /home/ark/.browser.py/qtwebengine_resources_200p.pak
ln -sfn "$GAMEDIR/locales" /home/ark/.browser.py/qtwebengine_locales

echo "=== ENVIRONMENT ==="
env | grep -E 'QT|PYTHON|LD_LIBRARY|XDG_RUNTIME|TERM'

echo "=== TEST PYQT5 ==="
python3 -c "import PyQt5; print('PyQt5 OK')"

echo "=== TEST QTCORE ==="
python3 -c "from PyQt5.QtCore import QUrl; print('QtCore OK')"

echo "=== SEARCHING SYSTEM FOR LIBEVENT ==="
find /usr /lib -name "libevent*.so*" 2>/dev/null | head -50

echo "=== TEST WEBENGINECORE ==="
python3 -c "from PyQt5.QtWebEngineWidgets import QWebEngineScript; print('WebEngineScript OK')"

echo "=== TEST WEBENGINEWIDGETS ==="
python3 -c "from PyQt5.QtWebEngineWidgets import QWebEngineView, QWebEnginePage, QWebEngineProfile; print('WebEngineWidgets OK')"

echo "=== LOCAL SERVER ==="
echo "browser.py provides the HTTP server on port 8765"

echo "=== MALI LIBRARY CHECK ==="
echo "--- /usr/local ---"
ls -la /usr/local/lib/aarch64-linux-gnu/ 2>&1 | grep -Ei "mali|egl|gles" || true
echo "--- /usr/lib ---"
ls -la /usr/lib/aarch64-linux-gnu/ 2>&1 | grep -Ei "mali|egl|gles" || true
echo "--- GPU/EGL environment ---"
env | grep -Ei "EGL|MALI|GBM|DRM|QT_QPA" || true

echo "=== GPU DIAGNOSTIC ==="
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage --ignore-gpu-blocklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers --enable-logging=stderr --v=1"

echo "=== STARTING BROWSER ==="

cd "$GAMEDIR"

python3 app/browser.py \
    "http://127.0.0.1:8765/index.html" \
    < /dev/tty1 2>&1 | tee -a "$LOG" > /dev/tty1

EXITCODE=${PIPESTATUS[0]}

echo "=== BROWSER EXITED ==="
echo "Exit code=$EXITCODE"

echo "=== END ==="

sleep 3
