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

	local filename=()
	for filename in $(ls -1 "${LOCAL_BIN_ROOT}"); do
		chmod +x ${LOCAL_BIN_ROOT}/${filename}
	done

	for filename in $(ls -1 "${LOCAL_CONFIG_ROOT}"); do
		rm -rf ${HOME_CONFIG_ROOT}/${filename}
		ln -sf ${LOCAL_CONFIG_ROOT}/${filename} ${HOME_CONFIG_ROOT}/${filename}
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
  export PIXI_HOME='${PIXI_HOME}'
  export PATH='${PIXI_HOME}'/bin:${PATH}
  ''' >>${DOTFILES_RC}

	local cmd=""
	case ${SHELL_NAME} in
	bash | zsh)
		cmd='eval "$(pixi completion --shell '${SHELL_NAME}')"'
		;;
	esac
	echo ${cmd} >>${DOTFILES_RC}

	echo "Done"
}

pixi_install_packages() {
	${PIXI_HOME}/bin/pixi global install -q ${1} &>/dev/null
}

setup_essentials() {
	echo -n "   essentials ... "
	pixi_install_packages "fd-find ripgrep lsdeluxe zoxide nvim"

	echo '''
  # Essentials setup
  alias ls=lsd
  alias cd=z
  ''' >>${DOTFILES_RC}

	local cmd=""
	case ${SHELL_NAME} in
	bash | zsh)
		cmd='eval "$(zoxide init '${SHELL_NAME}')"'
		;;
	esac
	echo ${cmd} >>${DOTFILES_RC}

	echo "Done"
}

setup_starship() {
	echo -n "   starship ... "
	pixi_install_packages starship

	local cmd=""
	case ${SHELL_NAME} in
	bash | zsh)
		cmd='eval "$(starship init '${SHELL_NAME}')"'
		;;
	esac

	echo '''
  # Starship setup
  if [[ ${TERM_PROGRAM} != "WarpTerminal" ]]; then
    '${cmd}'
  fi
  ''' >>${DOTFILES_RC}

	echo "Done"
}

setup_goodies() {
	echo -n "   goodies ..."
	pixi_install_packages ruff
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

install() {
	on_setup_begin &&
		setup_pixi &&
		setup_essentials &&
		setup_starship &&
		setup_goodies &&
		on_setup_end
}

uninstall() {
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

	for filename in $(ls -1 "${LOCAL_CONFIG_ROOT}"); do
		rm -rf ${HOME_CONFIG_ROOT}/${filename}
	done

	echo '`source '${SHELL_RC}'` might be required for changes to take place'
	echo "All done"
}

case $1 in
install)
	install
	;;

uninstall)
	uninstall
	;;

*)
	echo Argument could be either '`install`' or '`uninstall`', got '`'${1}'`'
	exit 1
	;;
esac
