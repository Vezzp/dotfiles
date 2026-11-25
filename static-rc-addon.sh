__SHELL_NAME=${SHELL##*/}
__SHELL_NAME=${__SHELL_NAME:-sh}

for vsc in code code-insiders; do
  if command -v "$vsc" >/dev/null 2>&1; then
    alias vsc="$vsc"
    break
  fi
done

case $__SHELL_NAME in
zsh)
  autoload -Uz compinit
  compinit
  ;;
esac

if command -v lsd >/dev/null 2>&1; then
  alias ls=lsd
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
fi

if command -v zoxide >/dev/null 2>&1; then
  case $__SHELL_NAME in
  bash | zsh)
    eval "$(zoxide init "$__SHELL_NAME")"
    ;;
  esac
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --decorations=never'
fi

case $__SHELL_NAME in
bash | zsh)
  eval "$(pixi completion --shell "$__SHELL_NAME")"
  ;;
esac

case $__SHELL_NAME in
bash)
  if [ -f "${PIXI_HOME}/envs/bash-completion/share/bash-completion/bash_completion" ]; then
    . "${PIXI_HOME}/envs/bash-completion/share/bash-completion/bash_completion"
  fi
  ;;
esac

if [ -d "${PIXI_HOME}/envs/nodejs/bin" ]; then
  export PATH="${PATH}:${PIXI_HOME}/envs/nodejs/bin"
fi

if command -v starship >/dev/null 2>&1; then
  if [ "${TERM_PROGRAM:-}" != WarpTerminal ]; then
    case $__SHELL_NAME in
    bash | zsh)
      eval "$(starship init "$__SHELL_NAME")"
      ;;
    esac
  fi
fi
