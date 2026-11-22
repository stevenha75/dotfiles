# ~/.agents: one source of truth for Codex + Claude Code

Edit files here, nowhere else. No sync step.

YAGNI: a file or setting lives here only while something on this Mac uses it.
Remove it when that stops, so the config only describes what is in use.

| File               | Codex                                   | Claude Code                                |
|--------------------|-----------------------------------------|--------------------------------------------|
| `AGENTS.md`        | `~/.codex/AGENTS.md` symlink (live)     | `~/.claude/CLAUDE.md` symlink (live)       |
| `.mcp.json`        | plugin `agents@home`, refreshed by hook | plugin `agents@home` (live)                |
| `hooks/hooks.json` | plugin `agents@home`                    | plugin `agents@home`                       |

`home/` holds hand-written dotfiles (zsh, git), each symlinked to the same
path under `~` (e.g. `~/.zshrc` → `home/.zshrc`). App-written configs
(`~/.claude/settings.json`, `~/.codex/config.toml`) stay unmanaged.

`hooks/session-start.sh` runs at every session start in both tools and, in the
background, refreshes Codex's copy of `agents@home` (picks up `.mcp.json` edits)
and updates `mar10@mar10tech` in both tools to agent-kit `main`. Net effect: any
change here or merged to agent-kit reaches both tools by the next session.

Editing `hooks/hooks.json` changes its hash, so Codex asks for re-trust: run
`codex` in a terminal → Review hooks → `t`.

Plumbing: `.claude-plugin/` (Claude plugin + marketplace), `.codex-plugin/`
(Codex plugin), `plugins/marketplace.json` (Codex auto-discovers it as `home`).
Both plugin manifests point `skills` at an empty dir so skills don't double-load.
Don't put secrets in `.mcp.json` (it's in git); reference env vars instead.

## Browser (Playwright MCP)

`playwright` in `.mcp.json` runs `bin/playwright-mcp`, which drives the main Brave
profile through the [Playwright extension](https://chromewebstore.google.com/detail/playwright-extension/mmlmfjhmonkocbjadbfplnigmagldckm),
so agents reuse your logins and passkeys. Each client gets its own tab group. The
extension token that skips the approval dialog is in the Keychain
(`playwright-mcp-extension-token`); after rotating it in the extension, re-run the
`security add-generic-password` line in `bin/playwright-mcp`.

## GitHub accounts

`gh-accounts` maps GitHub owners to `gh` accounts (personal vs work). Unlisted
owners use the active account (`gh auth switch`). Two scripts read it:

- `bin/gh` (first on PATH via `.zprofile`): runs `gh` as the account for the
  owner in `-R`/`--repo`, a GitHub URL, `repos|orgs/<owner>`, or the cwd's remote.
- `bin/git-credential-github` (`.gitconfig`): same for `git` push/pull/clone.

Commit identity: `.gitconfig-mar10tech` applies to repos under
`~/code/mar10tech/` or with a `mar10tech` remote.

## Team skills

tstack and other shared skills live in github.com/mar10tech/agent-kit, installed
as plugin `mar10@mar10tech` in both tools (Claude shows them as `mar10:<skill>`).
`disabled-skills/` holds personal skills that are turned off. Nothing loads
personal skills right now; turning one on means wiring `skills/` back up.
