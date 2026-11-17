# ~/.agents: one source of truth for Codex + Claude Code

Edit files here, nowhere else. No sync step.

| File               | Codex                                   | Claude Code                                |
|--------------------|-----------------------------------------|--------------------------------------------|
| `AGENTS.md`        | `~/.codex/AGENTS.md` symlink (live)     | `~/.claude/CLAUDE.md` symlink (live)       |
| `skills/`          | native user-skills dir (live)           | `~/.claude/skills/<name>` symlinks, created by the hook |
| `.mcp.json`        | plugin `agents@home`, refreshed by hook | plugin `agents@home` (live)                |
| `hooks/hooks.json` | plugin `agents@home`                    | plugin `agents@home`                       |

`home/` holds hand-written dotfiles (zsh, git), each symlinked to the same
path under `~` (e.g. `~/.zshrc` → `home/.zshrc`). App-written configs
(`~/.claude/settings.json`, `~/.codex/config.toml`) stay unmanaged.

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

## GitHub accounts

`gh-accounts` maps GitHub owners to `gh` accounts (personal vs work). Unlisted
owners use the active account (`gh auth switch`). Two scripts read it:

- `bin/gh` (first on PATH via `.zprofile`): runs `gh` as the account for the
  owner in `-R`/`--repo`, a GitHub URL, `repos|orgs/<owner>`, or the cwd's remote.
- `bin/git-credential-github` (`.gitconfig`): same for `git` push/pull/clone.

Commit identity: `.gitconfig-mar10tech` applies to repos under
`~/code/mar10tech/` or with a `mar10tech` remote.

## Updating tstack

`bin/tstack-update` merges upstream github.com/t3dotgg/tstack into `skills/`,
keeping local edits (3-way), and stages it for review. `skills/.tstack-rev`
records the upstream commit last merged.
