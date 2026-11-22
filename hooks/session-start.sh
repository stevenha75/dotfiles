#!/bin/sh
# Runs at session start in both Claude Code and Codex (via plugin agents@home).
# Refreshes installed plugins in the background; changes load next session.
(
  # Codex's cached copy of this repo's plugin (picks up .mcp.json edits).
  codex plugin add agents@home
  # Team skills (mar10tech/agent-kit main). Neither tool auto-updates a
  # third-party marketplace by default, so pull it into both here.
  # Each tool installs from its local marketplace snapshot, so pull that first.
  codex plugin marketplace upgrade mar10tech && codex plugin add mar10@mar10tech
  claude plugin marketplace update mar10tech && claude plugin update mar10@mar10tech
) </dev/null >/dev/null 2>&1 &
exit 0
