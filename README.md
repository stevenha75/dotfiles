# ~/.agents: one source of truth for Codex, Claude Code, and Antigravity CLI

Edit files here, nowhere else. No sync step.

YAGNI: a file or setting lives here only while something on this Mac uses it.
Remove it when that stops, so the config only describes what is in use.

| File               | Codex                                   | Claude Code                                | Antigravity CLI (`agy`)                          |
|--------------------|-----------------------------------------|--------------------------------------------|--------------------------------------------------|
| `AGENTS.md`        | `~/.codex/AGENTS.md` symlink (live)     | `~/.claude/CLAUDE.md` symlink (live)       | `~/.gemini/AGENTS.md` symlink (live)             |
| `.mcp.json`        | plugin `agents@home`, refreshed by hook | plugin `agents@home` (live)                | `~/.gemini/config/mcp_config.json` symlink (live) |
| `hooks/hooks.json` | plugin `agents@home`                    | plugin `agents@home`                       | not wired                                        |

`agy` has no plugin marketplace for agent-kit, so `~/.gemini/config/skills` is a
symlink to Claude Code's checkout of it
(`~/.claude/plugins/marketplaces/mar10tech/skills`), kept current by the Claude
hook below. Its billing project and default model live in
`~/.gemini/antigravity-cli/settings.json` (app-written, unmanaged).

Slack: Claude Code uses its claude.ai connector. `agy` gets Slack's hosted MCP
server from the plugin in `agy-plugins/slack`, backed by the internal Slack app
"Antigravity (Steven)". agy 1.5.14 got `Unauthorized` from Slack without ever
offering its own OAuth sign-in (likely because Slack's resource metadata names
`https://mcp.slack.com`, not `/mcp`), so the plugin sends a user token instead.
Get one by authorizing the app through `https://slack.com/oauth/v2_user/authorize`
with its `client_id`, its user scopes as `scope`, a PKCE challenge, and redirect
`https://antigravity.google/oauth-callback`. Exchange the code at
`oauth.v2.user.access` with the PKCE verifier and the client secret from the
app's Basic Information page. Then `agy plugin install
~/.agents/agy-plugins/slack` and paste the token in `/plugin`. The install is a
copy, so re-run it after editing the plugin. agy keeps the token in
`~/.gemini/config/config.json`, outside git. It never expires and can post as
you: if it leaks, call `auth.revoke` with it (or remove the app) and redo the
flow. The Gemini Enterprise MCP allowlist must list `slack_slack` →
`https://mcp.slack.com/mcp`. This covers terminal `agy` only; T3's private
profile has no Slack.

T3 Code runs `agy acp` with a private `GEMINI_HOME` under
`~/.t3/userdata/providers/antigravity/<hash>/`. T3 links the skills in itself;
`AGENTS.md` there is a hand-made symlink to this repo's `AGENTS.md`. Recreate
it if T3 rebuilds the profile. T3 sessions do not read `.mcp.json`; that
profile has its own MCP config.

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
