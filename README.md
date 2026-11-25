# ~/.agents: one source of truth for Codex, Claude Code, and Antigravity CLI

Edit files here, nowhere else. No sync step.

YAGNI: a file or setting lives here only while something on this Mac uses it.
Remove it when that stops, so the config only describes what is in use.

| File               | Codex                                   | Claude Code                                | Antigravity CLI (`agy`)                          |
|--------------------|-----------------------------------------|--------------------------------------------|--------------------------------------------------|
| `AGENTS.md`        | `~/.codex/AGENTS.md` symlink (live)     | `~/.claude/CLAUDE.md` symlink (live)       | `~/.gemini/AGENTS.md` symlink (live)             |
| `.mcp.json`        | plugin `agents@home`, refreshed by hook | plugin `agents@home` (live)                | `~/.gemini/config/mcp_config.json` symlink (live) |
| Session refresh    | `hooks/hooks.json` via `agents@home`      | `hooks/hooks.json` via `agents@home`         | `~/.gemini/config/hooks.json` → `hooks/antigravity.json` (terminal) |

`agy` has no plugin marketplace for agent-kit, so `~/.gemini/config/skills` links to
Claude Code's checkout (`~/.claude/plugins/marketplaces/mar10tech/skills`).
The terminal session hook runs the same refresh as Claude Code and Codex.
Antigravity billing and the default model live in
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
`https://mcp.slack.com/mcp`.

T3 Code runs `agy acp` with a private `--gemini-dir` under
`~/.t3/userdata/providers/antigravity/<hash>/`. The profile links to the shared
rules and skills. If T3 rebuilds it, check that `AGENTS.md` and `config/skills`
link to their counterparts in `~/.gemini`. Link `config/mcp_config.json` to `~/.agents/.mcp.json` (replacing only the
empty generated file). Copy the installed `config/plugins/slack` directory from
`~/.gemini` and merge just the `plugins.slack` entry into the private
`config/config.json`, keeping both config files private. Refresh the private
Slack copy after reinstalling the plugin or rotating its token. Linear needs
its own OAuth sign-in for each profile. ACP 1.5.14 did not run the terminal
session hook in testing, so T3 picks up skill updates from the shared checkout.

Claude's hosted connectors have their own authorization. Native Gmail,
Calendar, Drive, Docs, and Sheets on Gemini Enterprise need approved MCP
endpoints and Google Workspace OAuth setup.

`home/` holds hand-written dotfiles (zsh, git), each symlinked to the same
path under `~` (e.g. `~/.zshrc` → `home/.zshrc`).

`apps/` holds snapshots of app-written settings: Claude Code `settings.json`,
agy `settings.json`, and T3 Code's settings and keybindings. Codex's
`config.toml` isn't snapshotted because the ChatGPT app writes version-pinned
paths into it. `setup.sh` sets only its plugins and `model_verbosity`. Apps rewrite these files, so they are copied, not linked. After
changing settings on one Mac, run `./setup.sh save` (it refuses to save anything that looks like a credential),
commit, then run `./setup.sh` on the other. Secrets never go in `apps/`: the agy Slack token
(`~/.gemini/config/config.json`) and T3's `~/.t3/userdata/secrets` stay local.

## New machine

1. Install [Homebrew](https://brew.sh), then `brew install gh && gh auth login`
   (log in to both accounts in `gh-accounts`; `gh auth login` again adds the second).
2. `gh repo clone stevenha75/dotfiles ~/.agents`
3. Quit T3 Code, then run `~/.agents/setup.sh` from Terminal. It installs the
   `Brewfile`, oh-my-zsh, and rustup, links `home/`, `AGENTS.md`, `.mcp.json`
   and the agy hooks and skills, restores `apps/`, and installs the
   `agents@home`, `mar10@mar10tech`, and `s-kit@mar10tech` plugins in Claude
   Code and Codex. Anything it replaces is kept as `<name>.pre-agents`.
4. Sign in by hand: Claude Code, Codex, ChatGPT, `agy`, and T3 Code accounts;
   Linear MCP OAuth in each tool; the claude.ai connectors (Slack, Gmail, etc.)
   come with the Claude account.
5. Store the Playwright extension token (see Browser), set up the agy Slack
   plugin and T3's private agy profile (the Slack and T3 Code paragraphs above),
   and re-trust the Codex hook if Codex asks (see below).

`hooks/session-start.sh` runs at session start in Claude Code, Codex, and
terminal `agy`. It refreshes Codex's copy of `agents@home` (picks up `.mcp.json` edits)
and updates `mar10@mar10tech` (plus `s-kit@mar10tech` where it's installed) in
Claude Code and Codex to agent-kit `main` in the background. The new plugin versions load on the next session.

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
