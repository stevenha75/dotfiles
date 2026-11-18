eval "$(/opt/homebrew/bin/brew shellenv)"

# brew shellenv puts Homebrew first, so put the gh wrapper back in front
# (see ~/.agents/gh-accounts).
path=("$HOME/.agents/bin" $path)
