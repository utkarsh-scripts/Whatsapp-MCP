---
name: whatsapp-messaging
description: Use the connected personal WhatsApp MCP to search and analyze chats, find contacts, draft replies, and send explicitly approved messages.
---

# WhatsApp Messaging

Use the `whatsapp` MCP server for personal WhatsApp work.

## Safety rules

- Resolve a recipient to an unambiguous contact before sending.
- Show the recipient and exact final message when the user's instruction is
  ambiguous or when multiple contacts match.
- Draft-only requests must never send.
- Treat sending, reacting, marking read, or deleting as external actions.
- Do not expose phone numbers, private messages, session tokens, or local
  database paths unnecessarily.
- Reading and searching do not mark messages read automatically.

## Analysis

State the synchronized date range and important limitations. Voice notes,
calls, images, and videos may be present only as metadata unless their content
is separately inspected or transcribed. Do not claim that the local cache is a
lifetime archive because WhatsApp controls linked-device history depth.

## Sending

When the user gives an exact recipient and exact body, send it once. If either
is ambiguous, resolve or clarify first. Report success only after the tool
confirms delivery to WhatsApp.
