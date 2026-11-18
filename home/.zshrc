export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="apple"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# Homebrew's site-functions (on fpath via .zprofile) covers heroku, gh, etc.
# gcloud ships its zsh completion separately.
gcloud_completion=/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
[ -f "$gcloud_completion" ] && source "$gcloud_completion"

# Homebrew is set up in .zprofile, Cargo in .zshenv. -U drops duplicate entries.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.npm-global/bin"
  $path
  "/Applications/Racket v8.18/bin"
)
