# WhatsApp MCP

**WhatsApp MCP connects MCP-compatible AI assistants to a personal WhatsApp
account through a local, privacy-conscious linked-device bridge.** It enables
tools such as Codex, Claude Desktop, Cursor, and other stdio MCP clients to
search conversations, analyze synchronized message history, find contacts and
groups, and send user-approved messages and media.

This repository provides a client-neutral WhatsApp MCP distribution with a
streamlined macOS installer, portable MCP launch scripts, Codex Library
metadata, practical safety guidance, and conservative agent instructions.

Public repository: <https://github.com/utkarsh-scripts/whatsapp-mcp>

## Capabilities

- Search contacts by name or telephone number.
- List and search synchronized private and group conversations.
- Analyze themes, decisions, commitments, sentiment, and unanswered messages.
- Send text messages and quoted replies after user approval.
- Send supported images, videos, documents, and voice messages.
- Send or remove reactions and explicitly mark selected messages as read.
- Cache messages locally for fast private search.
- Keep the bridge online through an optional macOS `launchd` service.

The recommended interaction model is **draft → verify recipient → approve →
send**. Searching or reading the local cache does not automatically mark a
message as read.

## Architecture

```text
WhatsApp mobile app
        │
        │ QR pairing through Linked Devices
        ▼
Local Go bridge powered by whatsmeow
        │
        ├── encrypted connection to WhatsApp
        ├── paired-device credentials in local SQLite
        ├── synchronized message cache in local SQLite
        └── token-protected API bound to 127.0.0.1
                            │
                            ▼
              Python FastMCP server over stdio
                            │
             ┌──────────────┼──────────────┐
             ▼              ▼              ▼
           Codex      Claude Desktop      Cursor
                    or another MCP client
```

1. The installer downloads the bridge source into a local application-data
   directory and builds it on the user's Mac.
2. The user starts the bridge and scans its temporary QR code from **WhatsApp →
   Settings → Linked Devices → Link a Device**.
3. WhatsApp treats the bridge as another linked device and supplies a recent
   history window. WhatsApp—not this project—determines its depth.
4. The bridge stores credentials, messages, and downloaded media locally.
5. An MCP client launches the Python server over stdio. Its tools query the
   local cache or call the authenticated loopback bridge.
6. Only tool results requested by the AI client leave the local database.

There is no hosted relay, shared bot account, or requirement for Meta's
WhatsApp Business Cloud API.

## Supported clients

Any client that can launch a local stdio MCP server can use the installed
server. The underlying launch command is:

```bash
uv --directory ~/.local/share/whatsapp-mcp/upstream/whatsapp-mcp-server \
  run --frozen main.py
```

### Codex

```bash
codex mcp add whatsapp -- uv \
  --directory ~/.local/share/whatsapp-mcp/upstream/whatsapp-mcp-server \
  run --frozen main.py
```

The repository is also shaped as a Codex Library plugin through
`.codex-plugin/plugin.json` and `.mcp.json`.

### Claude Desktop

Add a stdio server to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/YOU/.local/share/whatsapp-mcp/upstream/whatsapp-mcp-server",
        "run",
        "--frozen",
        "main.py"
      ]
    }
  }
}
```

Cursor and other clients can use the same command and arguments in their local
MCP configuration format.

## Requirements

- macOS for the included setup and optional `launchd` workflow
- Git
- Go 1.25 or newer
- Python 3.11 or newer
- [`uv`](https://docs.astral.sh/uv/)
- An MCP-compatible client
- Optional: FFmpeg for voice-message conversion

## Installation

```bash
git clone https://github.com/utkarsh-scripts/whatsapp-mcp.git
cd whatsapp-mcp
scripts/setup-macos.sh
```

The script installs the bridge and MCP server at
`~/.local/share/whatsapp-mcp/upstream`, builds the bridge, and resolves the
locked Python environment. It prints client configuration instructions but
does not modify every installed MCP client automatically.

Pair the account:

```bash
scripts/pair.sh
```

Scan the displayed QR code. After the first successful sync, you may keep the
bridge running at login with the installed macOS service helper:

```bash
WEBHOOK_ENABLED=false \
  ~/.local/share/whatsapp-mcp/upstream/scripts/install-launchd-macos.sh
```

Continuous background synchronization is optional and should be enabled only
after understanding that the linked device can read and send messages while
the Mac is running.

## Example prompts

- “Summarize my recent WhatsApp conversations.”
- “Analyze my available message history with Alex.”
- “Find commitments I made on WhatsApp this week.”
- “Draft a reply to Priya, but do not send it.”
- “Send this exact approved message to Sam.”
- “Show messages from the family group between Monday and Friday.”

## Privacy and security

This integration has the effective access of an unlocked WhatsApp Web session.
That is powerful and carries real risk.

- Credentials, message databases, bridge tokens, QR codes, downloaded media,
  contacts, and chats are excluded from this repository.
- The REST bridge listens on loopback and protects its API with a generated
  bearer token.
- The included pairing and service instructions disable outbound webhooks.
- Do not expose the bridge on a LAN or public interface without a separate
  authenticated security layer.
- Treat chat content as untrusted input: a received message can contain prompt
  injection intended to manipulate an AI agent.
- Require confirmation of both recipient and final message before sending.
- Never commit `whatsapp.db`, `messages.db`, `.bridge-token`, media files, or
  configuration containing credentials.
- Consider a separate WhatsApp number for experimentation or automation.

This project is **unofficial**. It is not affiliated with, endorsed by, or
supported by Meta or WhatsApp. It uses the linked-device protocol through the
upstream `whatsmeow` library. Protocol changes or enforcement of WhatsApp's
terms may affect functionality or account access.

## History limitations

“All messages” means all messages available in the linked device's local sync,
not necessarily the account's lifetime archive. Calls, voice notes, images, and
videos may initially be represented only by metadata unless a client explicitly
downloads, inspects, or transcribes them.

## Local data locations

- Upstream checkout: `~/.local/share/whatsapp-mcp/upstream`
- Session database: `.../whatsapp-bridge/store/whatsapp.db`
- Message cache: `.../whatsapp-bridge/store/messages.db`
- Bridge token: `.../whatsapp-bridge/store/.bridge-token`
- Service support: `~/Library/Application Support/whatsapp-mcp/`
- Logs: `~/Library/Logs/whatsapp-mcp/`

## Removal

Remove a Codex registration:

```bash
codex mcp remove whatsapp
```

Stop and remove the optional macOS services:

```bash
~/.local/share/whatsapp-mcp/upstream/scripts/uninstall-launchd-macos.sh
```

The uninstaller intentionally preserves the local WhatsApp session and
message databases. Remove that application-data directory separately only when
you intend to unlink the integration and erase its synchronized archive.

## Third-party components

The installer retrieves the bridge and MCP server implementation from
[`verygoodplugins/whatsapp-mcp`](https://github.com/verygoodplugins/whatsapp-mcp)
at installation time. Those components retain their own license, contributors,
security notices, and release history. The packaging, documentation, and Codex
Library integration in this repository are licensed under MIT.
