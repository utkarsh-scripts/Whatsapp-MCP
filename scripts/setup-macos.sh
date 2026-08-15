#!/bin/sh
set -eu

state_root="${WHATSAPP_MCP_HOME:-$HOME/.local/share/whatsapp-mcp}"
upstream="$state_root/upstream"
upstream_url="https://github.com/verygoodplugins/whatsapp-mcp.git"

command -v git >/dev/null 2>&1 || { echo "Git is required." >&2; exit 1; }
command -v go >/dev/null 2>&1 || { echo "Go 1.25+ is required." >&2; exit 1; }
command -v uv >/dev/null 2>&1 || { echo "uv is required." >&2; exit 1; }
mkdir -p "$state_root"
if [ -d "$upstream/.git" ]; then
  git -C "$upstream" pull --ff-only
else
  git clone "$upstream_url" "$upstream"
fi

(cd "$upstream/whatsapp-bridge" && go build -o whatsapp-bridge .)
(cd "$upstream/whatsapp-mcp-server" && uv sync --frozen)

printf '%s\n' \
  "Setup complete." \
  "Run scripts/pair.sh and scan the QR code with WhatsApp." \
  "Point any stdio MCP client at: uv --directory $upstream/whatsapp-mcp-server run --frozen main.py" \
  "For Codex, run: codex mcp add whatsapp -- uv --directory $upstream/whatsapp-mcp-server run --frozen main.py" \
  "After pairing, enable macOS auto-start with:" \
  "  WEBHOOK_ENABLED=false $upstream/scripts/install-launchd-macos.sh"
