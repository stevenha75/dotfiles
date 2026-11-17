#!/bin/sh
# Runs at session start in both Claude Code and Codex (via plugin agents@home).
# 1. Expose ~/.agents/skills to Claude Code under plain names (Codex reads them natively).
mkdir -p "$HOME/.claude/skills"
for d in "$HOME"/.agents/skills/*/; do
  [ -f "$d/SKILL.md" ] || continue
  n=$(basename "$d"); t="$HOME/.claude/skills/$n"
  [ -e "$t" ] || [ -L "$t" ] || ln -s "${d%/}" "$t"
done
for l in "$HOME"/.claude/skills/*; do   # prune links to deleted shared skills
  [ -L "$l" ] && [ ! -e "$l" ] && case "$(readlink "$l")" in "$HOME"/.agents/skills/*) rm "$l";; esac
done
# 2. Refresh Codex's cached copy of the plugin (picks up .mcp.json edits).
(codex plugin add agents@home) </dev/null >/dev/null 2>&1 &
exit 0
