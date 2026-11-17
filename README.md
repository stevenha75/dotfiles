# ~/.agents: one source of truth for Codex + Claude Code

Edit files here, nowhere else. No sync step.

| File            | Codex                                       | Claude Code                       |
|-----------------|---------------------------------------------|-----------------------------------|
| `AGENTS.md`     | `~/.codex/AGENTS.md` symlink (live)         | `~/.claude/CLAUDE.md` symlink (live) |
| `skills/`       | native user-skills dir (live)               | plugin `agents@home` (live)       |
| `.mcp.json`     | plugin `agents@home` (next session*)         | plugin `agents@home` (live)       |
| `hooks/hooks.json` | plugin `agents@home` (needs trust in Settings → Hooks) | plugin `agents@home` (live) |

\* Codex caches plugin copies. The SessionStart hook re-runs
`codex plugin add agents@home` in the background, so `.mcp.json` edits reach
Codex on the session after next (or run that command yourself for immediate).

Plumbing: `.claude-plugin/` (Claude plugin + marketplace), `.codex-plugin/`
(Codex plugin; skills pointed at an empty dir to avoid double-loading),
`plugins/marketplace.json` (Codex auto-discovers this as marketplace `home`).
Codex hooks need a one-time trust approval (ChatGPT app: Settings → Hooks).
