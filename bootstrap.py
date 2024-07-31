#!:usr/bin/env python3

# ruff: noqa: UP032, T201, B028
# pyright: reportAny=false, reportUnusedCallResult=false

import argparse
import functools
import io
import os
import platform
import shutil
import stat
import subprocess
import tempfile
import textwrap
import warnings
from pathlib import Path
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from collections.abc import Callable
    from typing import Any

    from typing_extensions import ParamSpec, TypeVar, override

    _P = ParamSpec("_P")
    _R = TypeVar("_R")

else:

    def override(obj: "_R") -> "_R":
        return obj


REPO_HOME = Path(__file__).parent.resolve()
REPO_BIN = REPO_HOME / "bin"
REPO_CONFIG = REPO_HOME / "config"

USER_CONFIG = Path.home() / ".config"

PIXI_HOME = Path(os.environ.get("PIXI_HOME", Path.home().joinpath(".pixi"))).resolve()
PIXI_EXE = PIXI_HOME.joinpath("bin", "pixi")

INSTALL_STEP_FNS: "list[Callable[..., Any]]" = []


class StringBuilder(io.StringIO):
    def skipline(self) -> None:
        self.write("\n")

    @override
    def write(self, s: str) -> int:
        return super().write(textwrap.dedent(s))


RC_BUILDER = StringBuilder()
RC_PATH = REPO_HOME.joinpath("generated-rc")
RC_SOURCE_COMMAND = "source {}".format(RC_PATH)


def install_step(fn: "Callable[_P, _R]") -> "Callable[_P, _R]":
    INSTALL_STEP_FNS.append(fn)
    return fn


sh = functools.partial(
    subprocess.check_call,
    # stdout=subprocess.DEVNULL,
    # stderr=subprocess.DEVNULL,
)


def pixi_install_packages(*packages: str) -> None:
    assert len(packages) != 0
    if not PIXI_EXE.exists():
        raise RuntimeError("pixi was not installed properly")
    sh([str(PIXI_EXE), "global", "install", "-q", *packages])


@install_step
def on_setup_begin() -> None:
    # Make files in REPO_BIN executable for everyone, chmod +x.
    for exe_path in REPO_BIN.iterdir():
        exe_path.chmod(exe_path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    # Make symlinks from REPO_CONFIG items to USER_CONFIG items.
    for repo_sub_config_path in REPO_CONFIG.iterdir():
        user_sub_config_path = USER_CONFIG.joinpath(repo_sub_config_path.name)
        if user_sub_config_path.exists() and not user_sub_config_path.is_symlink():
            raise RuntimeError("{} is expected to be a symlink".format(user_sub_config_path))
        user_sub_config_path.unlink(missing_ok=True)
        user_sub_config_path.symlink_to(
            repo_sub_config_path,
            target_is_directory=repo_sub_config_path.is_dir(),
        )

    RC_BUILDER.write('export PATH="{}:$PATH"'.format(REPO_BIN))
    RC_BUILDER.skipline()

    RC_BUILDER.write(
        """\
        SHELL_NAME=$(basename $SHELL)

        for vsc in code code-insiders; do
            if [ ! -z $(which $vsc) ]; then
                alias vsc=$vsc
                break
            fi
        done

        case $SHELL_NAME in
        zsh)
            autoload -Uz compinit
            compinit
            ;;
        esac
        """
    )


@install_step
def setup_pixi() -> None:
    if shutil.which("pixi") is None and not PIXI_EXE.exists():
        curl_exe = shutil.which("curl")
        if curl_exe is None:
            raise RuntimeError("Cannot find curl")

        with tempfile.NamedTemporaryFile("w", suffix=".sh") as fout:
            sh(
                [
                    str(curl_exe),
                    "-fsSL",
                    "--output",
                    fout.name,
                    "https://pixi.sh/install.sh",
                ]
            )
            sh(["bash", fout.name])

    RC_BUILDER.write(
        """\
        # Pixi setup
        export PIXI_HOME={pixi_home}
        export PATH={pixi_home}/bin:$PATH

        case $SHELL_NAME in
        bash | zsh)
            eval "$(pixi completion --shell $SHELL_NAME)"
            ;;
        esac
        """.format(pixi_home=PIXI_HOME)
    )


@install_step
def setup_essentials() -> None:
    pixi_install_packages(
        "fd-find",
        "ripgrep",
        "lsdeluxe",
        "zoxide",
        "nvim",
        "coreutils",
        "htop",
        "bash-completion",
        "git",
        "bat",
    )
    RC_BUILDER.write(
        """\
        # Essentials setup
        if [ ! -z $(which lsd) ]; then
           alias ls=lsd
           alias l='ls -l'
           alias la='ls -a'
           alias lla='ls -la'
           alias lt='ls --tree'
        fi

        if [ ! -z $(which zoxide) ]; then
            case $SHELL_NAME in
            bash | zsh)
                eval "$(zoxide init $SHELL_NAME)"
                ;;
            esac
        fi

        if [ ! -z $(which bat) ]; then
            alias cat='bat --paging=never --decorations=never'
        fi
        """
    )
    RC_BUILDER.skipline()
    RC_BUILDER.write(
        """\
        case $SHELL_NAME in
        bash)
            . {}/envs/bash-completion/share/bash-completion/bash_completion
            ;;
        esac
        """.format(PIXI_HOME)
    )


@install_step
def setup_starship() -> None:
    pixi_install_packages("starship")
    RC_BUILDER.write(
        """\
        # Starship setup
        if [ ! -z $(which starship) ]; then
            if [[ ${TERM_PROGRAM} != "WarpTerminal" ]]; then
                case $SHELL_NAME in
                bash | zsh)
                    eval "$(starship init $SHELL_NAME)"
                    ;;
                esac
            fi
        fi
        """
    )


@install_step
def setup_tmux() -> None:
    pixi_install_packages("tmux")
    tpm_home = Path.home().joinpath(".tmux/plugins/tpm")
    if not tpm_home.is_dir():
        sh(["git", "clone", "-q", "https://github.com/tmux-plugins/tpm", str(tpm_home)])

    cmd_parts = ["bash", str(tpm_home.joinpath("bin", "install_plugins"))]
    try:
        sh(
            cmd_parts,
            env={
                **os.environ,
                "TMUX_PLUGIN_MANAGER_PATH": os.environ.get(
                    "TMUX_PLUGIN_MANAGER_PATH", str(tpm_home.parent)
                ),
            },
            cwd=tpm_home,
        )
    except Exception:
        warnings.warn(
            "Tmux plugin installation finished with error, try running {} manually".format(
                " ".join(cmd_parts)
            )
        )


@install_step
def install_goodies() -> None:
    pixi_install_packages("ruff")


def install_handler(guess_shell: bool) -> None:
    print("Installing dotfiles ...")
    if platform.system() == "Darwin":
        sh(["bash", "macos/setup"])

    for install_step_fn in INSTALL_STEP_FNS:
        install_step_fn()
        RC_BUILDER.skipline()

    RC_PATH.write_text(RC_BUILDER.getvalue())

    shell_rc = guess_shell_rc() if guess_shell else None
    if shell_rc is None:
        print("Cannot guess RC-file, add {} to it manually".format(RC_SOURCE_COMMAND))
    else:
        drop_line_from_file(shell_rc, RC_SOURCE_COMMAND)
        with shell_rc.open("a") as fout:
            fout.write(RC_SOURCE_COMMAND)
            fout.write("\n")
        print("Updated {}".format(shell_rc))


def uninstall_handler(guess_shell: bool) -> None:
    print("Uninstalling dotfiles ...")
    shell_rc = guess_shell_rc() if guess_shell else None
    if shell_rc is None:
        print("Cannot guess RC-file, remove {} from it manually".format(RC_SOURCE_COMMAND))
    else:
        drop_line_from_file(shell_rc, RC_SOURCE_COMMAND)
        print("Updated {}".format(shell_rc))


def guess_shell_rc() -> "Path | None":
    shell_name = guess_shell_name()
    if shell_name is None:
        return None

    if shell_name not in ("bash", "zsh"):
        raise RuntimeError("Shell {} is not supported".format(shell_name))

    rc_name = ".{}rc".format(shell_name)
    if shell_name == "bash" and platform.system() == "Darwin":
        rc_name = ".bash_profile"

    return Path.home().joinpath(rc_name)


def guess_shell_name() -> "str | None":
    shell_exe = os.getenv("SHELL", None)
    if shell_exe is None:
        return None
    _, shell_name = shell_exe.rsplit("/", 1)
    return shell_name


def drop_line_from_file(path: Path, line: str) -> None:
    line = line.strip()
    builder = StringBuilder()
    line_found = False
    for line_ in map(str.strip, path.open().readlines()):
        if line_ == line:
            line_found = True
        else:
            builder.write(line_)
            builder.skipline()

    if not line_found:
        return

    tmp_path = path.with_suffix(".bak")
    tmp_path.write_text(builder.getvalue())
    tmp_path.replace(path)


if __name__ == "__main__":

    def add_shell_argument(parser: "argparse.ArgumentParser") -> None:
        parser.add_argument(
            "--guess-shell",
            action="store_true",
            help="Guess shell and add sourcing generated RC-file",
        )
        parser.add_argument(
            "--no-guess-shell",
            action="store_false",
            help="No guess shell and add sourcing generated RC-file",
            dest="guess_shell",
        )
        parser.set_defaults(guess_shell=True)

    parser = argparse.ArgumentParser()

    subparsers = parser.add_subparsers()

    install_parser = subparsers.add_parser(
        "install", aliases=["i"], help="Install all packages and update shell-rc file"
    )
    add_shell_argument(install_parser)
    install_parser.set_defaults(handler=install_handler)

    uninstall_parser = subparsers.add_parser(
        "uninstall",
        aliases=["u"],
        help="Uninstall all packages and update shell-rc file",
    )
    add_shell_argument(uninstall_parser)
    uninstall_parser.set_defaults(handler=uninstall_handler)

    args = parser.parse_args()

    args.handler(args.guess_shell)
