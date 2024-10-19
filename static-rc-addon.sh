__SHELL_NAME=$(basename $SHELL)

for vsc in code code-insiders; do
  if [ ! -z $(which $vsc) ]; then
    alias vsc=$vsc
    break
  fi
done

case $__SHELL_NAME in
zsh)
  autoload -Uz compinit
  compinit
  ;;
esac

if [ ! -z $(which lsd) ]; then
  alias ls=lsd
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
fi

if [ ! -z $(which zoxide) ]; then
  case $__SHELL_NAME in
  bash | zsh)
    eval "$(zoxide init $__SHELL_NAME)"
    ;;
  esac
fi

if [ ! -z $(which bat) ]; then
  alias cat='bat --paging=never --decorations=never'
fi

case $__SHELL_NAME in
bash | zsh)
  eval "$(pixi completion --shell $__SHELL_NAME)"
  ;;
esac

case $__SHELL_NAME in
bash)
  if [ -f $PIXI_HOME/envs/bash-completion/share/bash-completion/bash_completion ]; then
    . $PIXI_HOME/envs/bash-completion/share/bash-completion/bash_completion
  fi
  ;;
esac

if [ ! -z $(which starship) ]; then
  if [[ ${TERM_PROGRAM} != "WarpTerminal" ]]; then
    case $__SHELL_NAME in
    bash | zsh)
      eval "$(starship init $__SHELL_NAME)"
      ;;
    esac
  fi
fi
