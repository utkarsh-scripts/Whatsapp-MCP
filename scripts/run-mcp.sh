#!/bin/sh
set -eu

state_root="${WHATSAPP_MCP_HOME:-$HOME/.local/share/whatsapp-mcp}"
upstream="$state_root/upstream"

if [ ! -x "$upstream/.runtime/uv/bin/uv" ] && ! command -v uv >/dev/null 2>&1; then
  echo "WhatsApp MCP is not set up. Run scripts/setup-macos.sh first." >&2
  exit 1
fi

if [ -x "$upstream/.runtime/uv/bin/uv" ]; then
  uv_bin="$upstream/.runtime/uv/bin/uv"
else
  uv_bin="$(command -v uv)"
fi

exec "$uv_bin" --directory "$upstream/whatsapp-mcp-server" run --frozen main.py
