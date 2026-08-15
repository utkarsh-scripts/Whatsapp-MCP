#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)

command -v go >/dev/null 2>&1 || { echo "Go 1.25+ is required." >&2; exit 1; }
command -v uv >/dev/null 2>&1 || { echo "uv is required." >&2; exit 1; }

(cd "$repo_root/whatsapp-bridge" && go build -o whatsapp-bridge .)
(cd "$repo_root/whatsapp-mcp-server" && uv sync --frozen)

printf '%s\n' \
  "Setup complete." \
  "Run scripts/pair.sh and scan the QR code with WhatsApp." \
  "Point any stdio MCP client at: uv --directory $repo_root/whatsapp-mcp-server run --frozen main.py" \
  "For Codex, run: codex mcp add whatsapp -- uv --directory $repo_root/whatsapp-mcp-server run --frozen main.py" \
  "After pairing, enable macOS auto-start with:" \
  "  WEBHOOK_ENABLED=false $repo_root/scripts/install-launchd-macos.sh"
