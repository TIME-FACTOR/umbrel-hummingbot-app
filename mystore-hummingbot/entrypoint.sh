#!/bin/bash
set -e

SOURCE_DIR="/home/hummingbot/source"
REPO_URL="https://github.com/hummingbot/hummingbot.git"

# If source/ is empty, clone so the app works out of the box (developer version from source)
if [ ! -f "${SOURCE_DIR}/setup.py" ]; then
  if [ -z "$(ls -A ${SOURCE_DIR} 2>/dev/null)" ]; then
    echo "First run: cloning Hummingbot into source/..."
    git clone --depth 1 "${REPO_URL}" "${SOURCE_DIR}"
  fi
fi

if [ ! -f "${SOURCE_DIR}/setup.py" ]; then
  echo "Developer version: put a Hummingbot clone in the app 'source' folder, then restart."
  echo "  git clone ${REPO_URL} <app-data>/source"
  exit 1
fi

# Start browser terminal early so /terminal is reachable; wrapper will attach once Hummingbot is ready.
ttyd -p 7681 -i 0.0.0.0 --writable /ttyd-hummingbot.sh &

echo "Installing Hummingbot from source (pip install -e)..."
: > /tmp/pip-install.log
pip install --no-cache-dir "pandas-ta>=0.4.71b0" 2>&1 | tee -a /tmp/pip-install.log || true
pip install --no-cache-dir -e "${SOURCE_DIR}" 2>&1 | tee -a /tmp/pip-install.log
pip install --no-cache-dir ptpython 2>&1 | tee -a /tmp/pip-install.log || true
echo "Replace files in source/ for custom models, then restart the app to apply."

# Start a persistent Hummingbot tmux session (if not already running).
if ! tmux has-session -t hb 2>/dev/null; then
  echo "Starting Hummingbot tmux session 'hb'..."
  tmux new-session -d -s hb "cd \"${SOURCE_DIR}\" && python3 bin/hummingbot_quickstart.py"
fi

# Keep the container running; Hummingbot lives inside tmux, ttyd attaches to it.
exec tail -f /dev/null
