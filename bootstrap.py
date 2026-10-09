#!/usr/bin/env python3

# ruff: noqa: UP032, T201, B028
# pyright: reportAny=false, reportUnusedCallResult=false, reportExplicitAny=false
# Minimum supported Python: 3.6 (compat shims: unlink_missing_ok, tarfile filter fallback)
import argparse
import contextlib
import hashlib
import inspect
import io
import os
import platform
import shutil
import stat
import subprocess
import tarfile
import tempfile
import urllib.request
import warnings
from pathlib import Path
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from collections.abc import Callable
    from typing import Any

    from typing_extensions import ParamSpec, TypeVar

    _P = ParamSpec("_P")
    _R = TypeVar("_R")


TERM = os.environ.get("TERM", "xterm-ghostty")

REPO_HOME = Path(__file__).parent.resolve()
REPO_BIN = REPO_HOME / "bin"
REPO_CONFIG_HOME = REPO_HOME / "config"
REPO_STATIC_RC_ADDON_PATH = REPO_HOME.joinpath("static-rc-addon.sh")
REPO_GENERATED_RC_ADDON_PATH = REPO_HOME.joinpath("generated-rc-addon.sh")

USER_CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
if not USER_CONFIG_HOME.is_dir():
    USER_CONFIG_HOME.mkdir(parents=True)

PIXI_HOME = Path(os.environ.get("PIXI_HOME", Path.home().joinpath(".pixi"))).resolve()
PIXI_EXE = Path(
    os.environ.get("PIXI_EXE", shutil.which("pixi") or PIXI_HOME.joinpath("bin", "pixi"))
)

PIXI_RELEASE_URL = "https://github.com/prefix-dev/pixi/releases/latest/download/{}"
PIXI_ASSETS = {
    ("Darwin", "arm64"): "pixi-aarch64-apple-darwin.tar.gz",
    ("Darwin", "x86_64"): "pixi-x86_64-apple-darwin.tar.gz",
    ("Linux", "x86_64"): "pixi-x86_64-unknown-linux-musl.tar.gz",
    ("Linux", "aarch64"): "pixi-aarch64-unknown-linux-musl.tar.gz",
}

INSTALL_STEPS: "list[Callable[..., Any]]" = []
UNINSTALL_STEPS: "list[Callable[..., Any]]" = []

RC_SOURCE_COMMAND = ". {}".format(REPO_GENERATED_RC_ADDON_PATH)


def install_step(fn: "Callable[_P, _R]") -> "Callable[_P, _R]":
    INSTALL_STEPS.append(fn)
    return fn


def uninstall_step(fn: "Callable[_P, _R]") -> "Callable[_P, _R]":
    UNINSTALL_STEPS.append(fn)
    return fn


# ----------
# Steps
# ----------


@install_step
def update_config_symlinks() -> None:
    """Update symlinks from repo config items to user config items."""
    for repo_sub_config_path, user_sub_config_path in get_repo_user_sub_config_symlinks():
        unlink_missing_ok(user_sub_config_path)
        user_sub_config_path.symlink_to(
            repo_sub_config_path,
            target_is_directory=repo_sub_config_path.is_dir(),
        )


@uninstall_step
def drop_config_symlinks():
    """Drop symlinks from repo config items to user config items."""
    for _, user_sub_config_path in get_repo_user_sub_config_symlinks():
        unlink_missing_ok(user_sub_config_path)


def pixi_sha256_of(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as fin:
        for chunk in iter(lambda: fin.read(1 << 20), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


@install_step
def setup_pixi() -> None:
    if PIXI_EXE.exists():
        warnings.warn("Existing pixi installation found at {}".format(PIXI_EXE), stacklevel=0)
        return

    asset = PIXI_ASSETS.get((platform.system(), platform.machine().lower()))
    if asset is None:
        raise RuntimeError(
            "Cannot download pixi for {} {}".format(platform.system(), platform.machine())
        )

    PIXI_EXE.parent.mkdir(parents=True, exist_ok=True)
    url = PIXI_RELEASE_URL.format(asset)
    print("Downloading pixi from {}".format(url))

    with tempfile.TemporaryDirectory() as tmp_dir:
        tar_path = Path(tmp_dir).joinpath(asset)
        with urllib.request.urlopen(url) as resp, tar_path.open("wb") as fout:
            shutil.copyfileobj(resp, fout)

        with urllib.request.urlopen(PIXI_RELEASE_URL.format(asset + ".sha256")) as resp:
            expected_sha256 = resp.read().decode().split()[0]

        actual_sha256 = pixi_sha256_of(tar_path)
        if actual_sha256 != expected_sha256:
            raise RuntimeError(
                "Checksum mismatch for {}: expected {}, got {}".format(
                    asset, expected_sha256, actual_sha256
                )
            )

        with tarfile.open(tar_path) as tar:
            pixi_members = [
                member
                for member in tar.getmembers()
                if member.isfile() and (member.name == "pixi" or member.name.endswith("/pixi"))
            ]
            if len(pixi_members) != 1:
                raise RuntimeError("Cannot find pixi binary inside {}".format(asset))
            try:
                tar.extract(pixi_members[0], path=tmp_dir, filter="data")
            except TypeError:
                # Extraction filters are 3.12+ (PEP 706; backported to 3.8.17+,
                # 3.9.17+, 3.10.12+, 3.11.4+). The tarball is sha256-verified
                # above, so plain extraction is acceptable on older interpreters.
                tar.extract(pixi_members[0], path=tmp_dir)
            tmp_exe = Path(tmp_dir).joinpath(pixi_members[0].name)

        tmp_exe.chmod(tmp_exe.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        # Smoke-test the binary directly; no shell involved.
        subprocess.check_call([str(tmp_exe), "--version"])
        shutil.move(str(tmp_exe), str(PIXI_EXE))


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
        "xclip",
        "rsync",
        "unzip",
        "starship",
        "tree-sitter-cli",
        "ncurses",
    )


@install_step
def setup_tmux() -> None:
    pixi_install_packages("tmux")
    tpm_home = USER_CONFIG_HOME.joinpath("tmux", "plugins", "tpm")
    tpm_home.parent.mkdir(parents=True, exist_ok=True)
    if not tpm_home.is_dir():
        subprocess.check_call(
            [
                str(PIXI_HOME.joinpath("bin", "git")),
                "clone",
                "-q",
                "https://github.com/tmux-plugins/tpm",
                str(tpm_home),
            ],
            env=installer_env(),
        )

    cmd_parts = ["bash", str(tpm_home.joinpath("bin", "install_plugins"))]
    try:
        subprocess.check_call(
            cmd_parts,
            env={
                **installer_env(),
                "TMUX_PLUGIN_MANAGER_PATH": os.environ.get(
                    "TMUX_PLUGIN_MANAGER_PATH", "{}{}".format(tpm_home.parent, os.sep)
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
def setup_herdr() -> None:
    """Install herdr workflow plugins used by the nvim navigation setup."""
    pixi_install_packages("herdr")
    try:
        # Absolute path: pixi-installed binaries are not guaranteed to be on
        # PATH, and Python resolves command names against the parent PATH
        # even when env= is passed.
        subprocess.check_call(
            [
                str(PIXI_HOME.joinpath("bin", "herdr")),
                "plugin",
                "install",
                "paulbkim-dev/vim-herdr-navigation",
                "-y",
            ],
            env=installer_env(),
        )
    except Exception:
        warnings.warn(
            "herdr plugin install failed; run "
            "`herdr plugin install paulbkim-dev/vim-herdr-navigation -y` manually"
        )


@install_step
def install_goodies() -> None:
    pixi_install_packages("ruff")


@install_step
def generate_rc_addon() -> None:
    with REPO_GENERATED_RC_ADDON_PATH.open("w") as fout:
        terminfo_dirs = []
        if os.environ.get("TERMINFO_DIRS") is not None:
            terminfo_dirs.append("$TERMINFO_DIRS")
        terminfo_dirs.append("{}/envs/ncurses/share/terminfo/".format(PIXI_HOME))

        fout.write(
            "\n".join(
                [
                    "export PATH={}:$PATH".format(REPO_BIN),
                    "export PIXI_HOME={}".format(PIXI_HOME),
                    "export PATH={}/bin:$PATH".format(PIXI_HOME),
                    "export TERM={}".format(TERM),
                    "export TERMINFO_DIRS={}".format(":".join(terminfo_dirs)),
                    REPO_STATIC_RC_ADDON_PATH.read_text(),
                ]
            )
        )


# ----------
# Main handlers
# ----------


def install(guess_shell: bool) -> None:
    print("Installing dotfiles ...")

    if platform.system() == "Darwin":
        subprocess.check_call(["bash", "macos/setup"])

    # Make files in REPO_BIN executable for everyone, chmod +x.
    for exe_path in REPO_BIN.iterdir():
        exe_path.chmod(exe_path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    for install_step_fn in INSTALL_STEPS:
        install_step_fn()

    shell_rc = guess_shell_rc() if guess_shell else None
    if shell_rc is None:
        print("Cannot guess RC-file, add {} to it manually".format(RC_SOURCE_COMMAND))
    else:
        drop_line_from_file(shell_rc, RC_SOURCE_COMMAND)
        with shell_rc.open("a") as fout:
            fout.write(RC_SOURCE_COMMAND)
            fout.write("\n")
        print("Updated {}".format(shell_rc))


def uninstall(guess_shell: bool) -> None:
    print("Uninstalling dotfiles ...")
    shell_rc = guess_shell_rc() if guess_shell else None
    if shell_rc is None:
        warnings.warn("Cannot guess RC-file, remove {} from it manually".format(RC_SOURCE_COMMAND))
    else:
        drop_line_from_file(shell_rc, RC_SOURCE_COMMAND)
        print("Updated {}".format(shell_rc))

    for uninstall_step_fn in UNINSTALL_STEPS:
        uninstall_step_fn()


# ----------
# Utils
# ----------


def unlink_missing_ok(path: Path) -> None:
    """Path.unlink(missing_ok=True) equivalent, available since Python 3.8 only."""
    with contextlib.suppress(FileNotFoundError):
        path.unlink()


def pixi_install_packages(*packages: str) -> None:
    assert len(packages) != 0
    if not PIXI_EXE.exists():
        raise RuntimeError("pixi was not installed properly")
    subprocess.check_call([str(PIXI_EXE), "global", "install", "-q", *packages])


def installer_env() -> "dict[str, str]":
    pixi_bin = str(PIXI_HOME.joinpath("bin"))
    path_parts = os.environ.get("PATH", os.defpath).split(os.pathsep)
    env_path = (
        os.pathsep.join([pixi_bin, *path_parts])
        if pixi_bin not in path_parts
        else os.environ.get("PATH", os.defpath)
    )
    return {
        **os.environ,
        "PATH": env_path,
        "GIT_CONFIG_COUNT": "1",
        "GIT_CONFIG_KEY_0": "safe.directory",
        "GIT_CONFIG_VALUE_0": "*",
    }


def get_repo_user_sub_config_symlinks() -> "list[tuple[Path, Path]]":
    out: list[tuple[Path, Path]] = []
    for repo_sub_config_path in REPO_CONFIG_HOME.iterdir():
        user_sub_config_path = USER_CONFIG_HOME.joinpath(repo_sub_config_path.name)
        if user_sub_config_path.exists() and not user_sub_config_path.is_symlink():
            raise RuntimeError("{} is expected to be a symlink".format(user_sub_config_path))
        out.append((repo_sub_config_path, user_sub_config_path))
    return out


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
    builder = io.StringIO()
    line_found = False
    with path.open() as fin:
        for line_ in map(str.strip, fin.readlines()):
            if line_ == line:
                line_found = True
            else:
                builder.write(line_)
                builder.write("\n")

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

    main_subparsers = parser.add_subparsers(dest="main_cmd")

    install_parser = main_subparsers.add_parser(
        "install", aliases=["i"], help="Install all packages and update shell-rc file"
    )
    add_shell_argument(install_parser)
    install_parser.set_defaults(handler=install)

    uninstall_parser = main_subparsers.add_parser(
        "uninstall",
        aliases=["u"],
        help="Uninstall all packages and update shell-rc file",
    )
    add_shell_argument(uninstall_parser)
    uninstall_parser.set_defaults(handler=uninstall)

    config_parser = main_subparsers.add_parser("config", help="Manipulate user config")
    config_subparsers = config_parser.add_subparsers(dest="config_cmd")

    config_update_parser = config_subparsers.add_parser(
        "update",
        help="Update user config symlinks associated with repo",
    )
    config_update_parser.set_defaults(handler=update_config_symlinks)

    config_remove_parser = config_subparsers.add_parser(
        "remove", help="Remove user config symlinks associated with repo"
    )
    config_remove_parser.set_defaults(handler=drop_config_symlinks)

    rc_parser = main_subparsers.add_parser("rc", help="Manipulate RC file")
    rc_subparsers = rc_parser.add_subparsers(dest="rc_cmd")

    rc_generate_parser = rc_subparsers.add_parser("generate", help="Generate RC addon")
    rc_generate_parser.set_defaults(handler=generate_rc_addon)

    args = parser.parse_args()
    args.handler(
        **{key: getattr(args, key) for key in inspect.signature(args.handler).parameters}
    )
