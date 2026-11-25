#!/bin/sh
# Rebuilds this harness (Claude Code, Codex, agy, T3 Code) on a Mac.
#   ./setup.sh        apply: install tools, link configs, restore app settings, install plugins
#   ./setup.sh save   copy this Mac's app-written settings into apps/ to commit
# Re-runnable. Anything it replaces is kept beside it as <name>.pre-agents[.<time>].
set -eu
A="$HOME/.agents"  # links point here; hooks and .mcp.json expect this path
cd "$(dirname "$0")"

# App-written settings, as "<snapshot in apps/> <path under ~>". Apps rewrite
# these files, so they are copied rather than linked. Snapshots spell $HOME as __HOME__.
# Codex's config.toml is left out: the ChatGPT app writes version-pinned paths
# into it, so only the keys below are set there.
APPS='
claude/settings.json      .claude/settings.json
agy/settings.json         .gemini/antigravity-cli/settings.json
t3/settings.json          .t3/userdata/settings.json
t3/client-settings.json   .t3/userdata/client-settings.json
t3/keybindings.json       .t3/userdata/keybindings.json
'

if [ "${1:-}" = save ]; then
  printf '%s\n' "$APPS" | while read -r snap live; do
    [ -n "$snap" ] || continue
    mkdir -p "apps/$(dirname "$snap")"
    tmp="apps/$snap.tmp"
    sed "s|$HOME|__HOME__|g" "$HOME/$live" > "$tmp"
    # apps/ is committed, so refuse anything that looks like a credential
    # (printing only where it is, not the value).
    if grep -niE '(token|secret|password|api_?key)s?"? *[:=]|xox[a-z]-|gh[pousr]_|sk-[A-Za-z0-9]{20}' "$tmp" |
      cut -d: -f1 | sed "s|^|possible secret: ~/$live line |" | grep . >&2; then
      rm "$tmp"
      exit 1
    fi
    mv "$tmp" "apps/$snap"
  done
  git status --short apps
  exit 0
fi

# Move whatever is at a path aside, keeping earlier backups.
backup() {
  [ -e "$1" ] || [ -L "$1" ] || return 0
  b="$1.pre-agents"
  [ -e "$b" ] || [ -L "$b" ] && b="$b.$(date +%s)"
  mv "$1" "$b"
  echo "moved $1 to $b"
}

# link <target> <path under ~>
link() {
  dest="$HOME/$2"
  [ "$(readlink "$dest" 2>/dev/null)" = "$1" ] && return
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  ln -s "$1" "$dest"
}

# Tools. A Brew failure (often an app installed outside Brew) doesn't stop the
# harness setup, but setup exits nonzero at the end. The installers run with
# flags that keep them from editing the linked dotfiles.
brew_ok=1
brew bundle --file Brewfile || brew_ok=0
tmp=$(mktemp)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  curl -fsSL -o "$tmp" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp"
fi
if [ ! -f "$HOME/.cargo/env" ]; then
  curl --proto '=https' --tlsv1.2 -fsSL -o "$tmp" https://sh.rustup.rs
  sh "$tmp" -y --no-modify-path
fi
rm -f "$tmp"

# Hand-written dotfiles: ~/<path> -> home/<path>.
git ls-files home | sed 's|^home/||' | while read -r f; do link "$A/home/$f" "$f"; done

# Shared rules, MCP servers, and hooks.
link "$A/AGENTS.md" .claude/CLAUDE.md
link "$A/AGENTS.md" .codex/AGENTS.md
link "$A/AGENTS.md" .gemini/AGENTS.md
link "$A/.mcp.json" .gemini/config/mcp_config.json
link "$A/hooks/antigravity.json" .gemini/config/hooks.json
link "$A/skills" .gemini/config/skills

# App-written settings.
printf '%s\n' "$APPS" | while read -r snap live; do
  [ -n "$snap" ] || continue
  dest="$HOME/$live"
  tmp=$(mktemp)
  sed "s|__HOME__|$HOME|g" "apps/$snap" > "$tmp"
  if cmp -s "$tmp" "$dest"; then rm "$tmp"; continue; fi
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  mv "$tmp" "$dest"
done

# Codex: a top-level key has to come before the first [table], so prepend it.
cfg="$HOME/.codex/config.toml"
touch "$cfg"
if ! sed '/^[[:space:]]*\[/q' "$cfg" | grep -qE '^[[:space:]]*model_verbosity[[:space:]]*='; then
  { echo 'model_verbosity = "low"'; cat "$cfg"; } > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
fi

# Plugins. The home marketplace is declared in the restored settings;
# `add` fills the local snapshot that `install` reads.
claude plugin marketplace add "$A"
claude plugin install agents@home
codex plugin add agents@home

if [ "$brew_ok" = 0 ]; then
  echo 'Done, except brew bundle had failures (above). Fix them and re-run.' >&2
  exit 1
fi
echo 'Done. Sign-ins and the Slack token are manual: see "New machine" in README.md.'
