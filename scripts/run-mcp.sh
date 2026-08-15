#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)

if ! command -v uv >/dev/null 2>&1; then
  echo "WhatsApp MCP is not set up. Run scripts/setup-macos.sh first." >&2
  exit 1
fi

uv_bin="$(command -v uv)"

exec "$uv_bin" --directory "$repo_root/whatsapp-mcp-server" run --frozen main.py
