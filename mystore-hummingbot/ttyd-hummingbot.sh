#!/bin/bash
# Attach to the long-running Hummingbot tmux session started by entrypoint.
if ! tmux has-session -t hb 2>/dev/null; then
  echo "Hummingbot is still starting. If this is the first boot, wait a few minutes, then refresh."
  exit 1
fi
exec tmux attach-session -t hb
