#!/bin/sh
# Runs at session start in Claude Code, Codex, and terminal agy.
# Refreshes Codex's cached copy of agents@home in the background; changes load next session.
(
  codex plugin add agents@home
) </dev/null >/dev/null 2>&1 &
exit 0
