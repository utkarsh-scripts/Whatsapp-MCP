#!/bin/sh
set -eu

state_root="${WHATSAPP_MCP_HOME:-$HOME/.local/share/whatsapp-mcp}"
bridge="$state_root/upstream/whatsapp-bridge/whatsapp-bridge"

if [ ! -x "$bridge" ]; then
  echo "Bridge not found. Run scripts/setup-macos.sh first." >&2
  exit 1
fi

cd "$(dirname "$bridge")"
exec env WEBHOOK_ENABLED=false WHATSAPP_DEVICE_NAME="Codex WhatsApp MCP" "$bridge"
