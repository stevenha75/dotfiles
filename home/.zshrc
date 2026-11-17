# =============================================================================
# Oh My Zsh Configuration
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="apple"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# =============================================================================
# Third-Party Tools
# =============================================================================

# Heroku Autocomplete
HEROKU_AC_ZSH_SETUP_PATH=/Users/stevenha/Library/Caches/heroku/autocomplete/zsh_setup && \
  test -f "$HEROKU_AC_ZSH_SETUP_PATH" && source "$HEROKU_AC_ZSH_SETUP_PATH"

# Google Cloud SDK
[ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ] && source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ] && source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"

# =============================================================================
# PATH Configuration
# =============================================================================
# Homebrew is initialized once in .zprofile and Cargo once in .zshenv.
# A unique zsh path array prevents tools from appending duplicate entries.
typeset -U path PATH
path=(
  "$HOME/.antigravity/antigravity/bin"
  "$HOME/.local/bin"
  "$HOME/.npm-global/bin"
  "$HOME/.cargo/bin"
  $path
  "/Applications/Racket v8.18/bin"
)
export PATH

# =============================================================================
# Aliases
# =============================================================================
