#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
bridge="$repo_root/whatsapp-bridge/whatsapp-bridge"

if [ ! -x "$bridge" ]; then
  echo "Bridge not found. Run scripts/setup-macos.sh first." >&2
  exit 1
fi

cd "$(dirname "$bridge")"
exec env WEBHOOK_ENABLED=false WHATSAPP_DEVICE_NAME="Codex WhatsApp MCP" "$bridge"
