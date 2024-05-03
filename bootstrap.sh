__file__=${BASH_SOURCE}
__root__=$(realpath $(dirname ${__file__}))

PIXI_HOME=${HOME}/.pixi

LOCAL_BIN_ROOT=${__root__}/bin

LOCAL_CONFIG_ROOT=${__root__}/config
HOME_CONFIG_ROOT=${HOME}/.config

SHELL_NAME=$(basename ${SHELL})
case ${SHELL_NAME} in
bash | zsh)
	SHELL_RC=${HOME}/.${SHELL_NAME}rc
	;;

*)
	echo Shell ${SHELL_NAME} is unsupported
	exit 1
	;;
esac

DOTFILES_RC=${__root__}/generated-dotfiles-rc/${SHELL_NAME}.sh

on_setup_begin() {
	echo "Setting up dotfiles"

	mkdir -p "$(dirname ${DOTFILES_RC})"

	if [ -f ${DOTFILES_RC} ]; then
		truncate -s 0 ${DOTFILES_RC}
	else
		touch ${DOTFILES_RC}
	fi

	for filename in "${LOCAL_BIN_ROOT}/*"; do
		chmod +x $filename
	done

	echo '''
  autoload -Uz compinit
  compinit

  export PATH="'${LOCAL_BIN_ROOT}':${PATH}"

  for vsc in code code-insiders; do
      if [ ! -z $(which "${vsc}") ]; then
          alias vsc="${vsc}"
          break
      fi
  done
  ''' >>${DOTFILES_RC}
}

setup_pixi() {
	echo -n "   pixi ... "

	if [ ! $"(which pixi &> /dev/null)" ]; then
		export PIXI_HOME=${PIXI_HOME} curl -fsSL https://pixi.sh/install.sh | ${SHELL}
	fi

	echo '''
  # Pixi setup 
  export PIXI_HOME='${PIXI_HOME}'
  export PATH=${PIXI_HOME}/bin:${PATH}

  case ${SHELL} in
    *bash*|*zsh*)
      eval "$(pixi completion --shell $(basename ${SHELL}))"
    ;;
  esac
  ''' >>${DOTFILES_RC}

	echo "Done"
}

pixi_install_packages() {
	${PIXI_HOME}/pixi/bin global install -q ${1} &>/dev/null
}

setup_essentials() {
	echo -n "   essentials ... "
	pixi_install_packages "fd-find ripgrep lsdeluxe zoxide"

	echo '''
  # Essentials setup  
  alias ls=lsd

  case ${SHELL} in
    *bash*|*zsh*)
      eval "$(zoxide init $(basename ${SHELL}))"
    ;;
  esac

  alias cd=z
  ''' >>${DOTFILES_RC}

	echo "Done"
}

setup_starship() {
	echo -n "   starship ... "
	pixi_install_packages starship

	rm -f ${HOME_CONFIG_ROOT}/starship.toml
	ln -sf ${LOCAL_CONFIG_ROOT}/starship.toml ${HOME}/.config/starship.toml

	echo '''
  # Starship setup
  case ${SHELL} in
    *bash*|*zsh*)
      eval "$(starship init $(basename ${SHELL}))"
    ;;

    *)
      echo Cannot initialize starship for $(basename ${SHELL})
  esac
  ''' >>${DOTFILES_RC}

	echo "Done"
}

setup_neovim() {
	echo -n "   neovim ... "
	pixi_install_packages nvim

	rm -rf ${HOME_CONFIG_ROOT}/nvim
	ln -sf ${LOCAL_CONFIG_ROOT}/nvim ${HOME_CONFIG_ROOT}/nvim

	echo "Done"
}

on_setup_end() {
	local shell_rc_init_cmd="source '${DOTFILES_RC}'"
	if grep -qF "${shell_rc_init_cmd}" "${SHELL_RC}"; then
		echo "System config ${SHELL_RC} already contains dotfile initialization"
	else
		echo ${shell_rc_init_cmd} >>${SHELL_RC}
	fi

	echo "All done"
}

main() {
	on_setup_begin &&
		setup_pixi &&
		setup_essentials &&
		setup_starship &&
		setup_neovim &&
		on_setup_end
}

main
