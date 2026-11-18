---
name: slack
description: Use when asked to read, search, or send Slack messages.
---

Claude has no Slack. Route it through Codex: `delegate_task` to the Codex
provider with everything it needs (it has no chat history): the action,
recipient or channel, and full message text. Report what it did.
