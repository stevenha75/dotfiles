# ~/.agents: one source of truth for Codex + Claude Code

Edit files here, nowhere else. No sync step.

| File               | Codex                                   | Claude Code                                |
|--------------------|-----------------------------------------|--------------------------------------------|
| `AGENTS.md`        | `~/.codex/AGENTS.md` symlink (live)     | `~/.claude/CLAUDE.md` symlink (live)       |
| `skills/`          | native user-skills dir (live)           | `~/.claude/skills/<name>` symlinks, created by the hook |
| `.mcp.json`        | plugin `agents@home`, refreshed by hook | plugin `agents@home` (live)                |
| `hooks/hooks.json` | plugin `agents@home`                    | plugin `agents@home`                       |

`hooks/session-start.sh` runs at every session start in both tools: links new
skills into `~/.claude/skills` (plain names, no `agents:` prefix), prunes links
to deleted ones, and runs `codex plugin add agents@home` in the background so
Codex's cached plugin copy picks up `.mcp.json` edits. Net effect: any change
reaches both tools by the next session.

Editing `hooks/hooks.json` changes its hash, so Codex asks for re-trust: run
`codex` in a terminal → Review hooks → `t`.

Plumbing: `.claude-plugin/` (Claude plugin + marketplace), `.codex-plugin/`
(Codex plugin), `plugins/marketplace.json` (Codex auto-discovers it as `home`).
Both plugin manifests point `skills` at an empty dir so skills don't double-load.
Don't put secrets in `.mcp.json` (it's in git); reference env vars instead.
