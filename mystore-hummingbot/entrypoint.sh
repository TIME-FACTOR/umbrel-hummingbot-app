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

echo "Installing Hummingbot from source (pip install -e)..."
pip install --no-cache-dir -e "${SOURCE_DIR}"
echo "Replace files in source/ for custom models, then restart the app to apply."
exec hummingbot
