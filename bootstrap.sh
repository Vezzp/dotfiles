__file__=${BASH_SOURCE}
__root__=$(realpath $(dirname ${__file__}))

PIXI_HOME=${PIXI_HOME:-"$HOME/.pixi"}

LOCAL_BIN_ROOT=${__root__}/bin

LOCAL_CONFIG_ROOT=${__root__}/config
HOME_CONFIG_ROOT=${HOME}/.config

SHELL_NAME=$(basename ${SHELL})
case ${SHELL_NAME} in
bash)
	if [ -f ${HOME}/.bash_profile ]; then
		SHELL_RC=${HOME}/.${SHELL_NAME}_profile
	else
		SHELL_RC=${HOME}/.${SHELL_NAME}rc
	fi
	;;

zsh)
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
  export PATH="'${LOCAL_BIN_ROOT}':${PATH}"

  for vsc in code code-insiders; do
      if [ ! -z $(which "${vsc}") ]; then
          alias vsc="${vsc}"
          break
      fi
  done
  ''' >>${DOTFILES_RC}

	case ${SHELL_NAME} in
	zsh)
		echo '''
      autoload -Uz compinit
      compinit
      ''' >>${DOTFILES_RC}
		;;
	esac
}

setup_pixi() {
	echo -n "   pixi [${PIXI_HOME}] ... "

	if ! command -v pixi &>/dev/null; then
		export PIXI_HOME=${PIXI_HOME} PIXI_NO_PATH_UPDATE=1 && curl -fsSL https://pixi.sh/install.sh | ${SHELL}
	fi

	echo '''
  # Pixi setup
  export PATH='${PIXI_HOME}'/bin:${PATH}

  case ${SHELL} in
    *bash*|*zsh*)
      eval "$(pixi completion --shell $(basename ${SHELL}))"
    ;;
  esac
  ''' >>${DOTFILES_RC}

	echo "Done"
}

pixi_install_packages() {
	${PIXI_HOME}/bin/pixi global install -q ${1} &>/dev/null
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
		echo "System config at ${SHELL_RC} already contains dotfile initialization"
	else
		echo ${shell_rc_init_cmd} >>${SHELL_RC}
	fi

	echo '`source '${SHELL_RC}'` might be required for changes to take place'
	echo "All done"
}

un_setup() {
	echo Uninstall will remove global pixi installation at ${PIXI_HOME} \
		and delete dotfiles settings sourcing from ${SHELL_RC}
	echo

	while true; do
		read -p "Shall we proceed? [yn] " confirmation
		case ${confirmation} in
		y)
			break
			;;

		n)
			echo Uninstallation aborted
			exit 0
			;;

		*)
			echo Unsupported option '`'${confirmation}'`', expected '`[yn]`'
			continue
			;;
		esac
	done

	local shell_rc_init_cmd="source '${DOTFILES_RC}'"
	grep -v "${shell_rc_init_cmd}" "${SHELL_RC}" >"${SHELL_RC}.bak" &&
		mv "${SHELL_RC}.bak" "${SHELL_RC}"

	(cat "${DOTFILES_RC}" |
		grep alias |
		awk -F "=" '{print $1}' |
		awk -F " " '{print $2}' |
		xargs unalias) &>/dev/null

	rm -fr ${PIXI_HOME}

	echo '`source '${SHELL_RC}'` might be required for changes to take place'
	echo "All done"
}

case $1 in
install)
	on_setup_begin &&
		setup_pixi &&
		setup_essentials &&
		setup_starship &&
		setup_neovim &&
		on_setup_end
	;;

uninstall)
	un_setup
	;;

*)
	echo Argument could be either $(install) or $(uninstall), got $(${1})
	exit 1
	;;
esac
