import ctypes
import os
import platform
import re
import shutil
import subprocess
import sys
import urllib.request
import zipfile

NVIM_VERSION      = "0.12.0"
NODE_VERSION      = "25"
NVM_VERSION       = "0.40.6"
WIN32YANK_VERSION = "0.1.1"
MIN_GO_VERSION    = (1, 21)

NVM_INSTALL_URL = f"https://raw.githubusercontent.com/nvm-sh/nvm/v{NVM_VERSION}/install.sh"
NVIM_URL        = f"https://github.com/neovim/neovim/releases/download/v{NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
WIN32YANK_URL   = f"https://github.com/equalsraf/win32yank/releases/download/v{WIN32YANK_VERSION}/win32yank-x64.zip"

NVM_SOURCE = 'export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh";'

LINUX_PACKAGES = {
    "Essential build tools": ["build-essential", "cmake", "curl", "wget", "git"],
    "Mason dependencies": ["unzip", "python3-pip", "python3-venv", "ripgrep"],
    "Go": ["golang-go"],
    "C/C++ tools": ["clang", "gdb"],
}

WINDOWS_PACKAGES = {
    "Essential build tools": [f"neovim@{NVIM_VERSION}", "mingw", "cmake", "git", "python"],
    "Mason dependencies": ["7zip", "ripgrep", "tree-sitter"],
    "Go": ["go"],
    "Clipboard": ["win32yank"],
}

WINDOWS_PROBES = {
    f"neovim@{NVIM_VERSION}": "nvim",
    "mingw": "gcc",
    "cmake": "cmake",
    "git": "git",
    "python": "python",
    "7zip": "7z",
    "ripgrep": "rg",
    "tree-sitter": "tree-sitter",
    "go": "go",
    "win32yank": "win32yank",
}

WINDOWS_ENV_VARS = ("NVM_HOME", "NVM_SYMLINK")

SEPARATOR = "=" * 50
FAILURES = []

# --- Colors ---
RESET  = "\x1b[0m"
GRAY   = "\x1b[0;36m"
RED    = "\x1b[0;31m"
GREEN  = "\x1b[0;32m"
ORANGE = "\x1b[0;33m"

def enable_windows_vt():
    ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
    STD_OUTPUT_HANDLE = -11

    try:
        kernel32 = ctypes.windll.kernel32
        handle = kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
        mode = ctypes.c_uint32()
        if not kernel32.GetConsoleMode(handle, ctypes.byref(mode)):
            return False
        return bool(kernel32.SetConsoleMode(
            handle, mode.value | ENABLE_VIRTUAL_TERMINAL_PROCESSING))
    except (AttributeError, OSError):
        return False


def supports_color():
    if os.environ.get("NO_COLOR"):
        return False
    if not sys.stdout.isatty():
        return False
    if platform.system() == "Windows":
        return enable_windows_vt()
    return True


USE_COLOR = supports_color()
def paint(color, text):
    return f"{color}{text}{RESET}" if USE_COLOR else text


# --- Logs ---
def section(title, color=None):
    print(f"\n{SEPARATOR}")
    print(paint(color, title) if color else title)
    print(SEPARATOR)


def log(msg):
    print(paint(GRAY, f"[*] {msg}"))


def ok(msg):
    print(paint(GREEN, f"[+] {msg}"))


def warn(msg):
    print(paint(ORANGE, f"[!] {msg}"))


def err(msg):
    print(paint(RED, f"[-] {msg}"))


def record_failure(label, detail=None):
    FAILURES.append(label)
    err(f"{label} failed" + (f": {detail}" if detail else ""))


# --- Commands ---
def check_command_exists(cmd):
    return shutil.which(cmd) is not None


def run_command(cmd, shell=False, label=None):
    if shell:
        target = cmd
    else:
        parts = cmd.split() if isinstance(cmd, str) else list(cmd)
        resolved = shutil.which(parts[0])
        if resolved is None:
            record_failure(label or parts[0], f"{parts[0]} not found on PATH")
            return False
        target = [resolved] + parts[1:]

    try:
        subprocess.run(target, check=True, shell=shell, capture_output=True, text=True)
        return True
    except FileNotFoundError:
        record_failure(label or "command", "executable not found")
        return False
    except subprocess.CalledProcessError as e:
        output = (e.stderr or e.stdout or "").strip().splitlines()
        record_failure(label or "command",
                       output[-1] if output else f"exit code {e.returncode}")
        return False


def run_bash(script, label=None):
    return run_command(["bash", "-c", script], label=label)


def capture_output(cmd):
    parts = cmd.split()
    resolved = shutil.which(parts[0])
    if resolved is None:
        return None

    try:
        result = subprocess.run([resolved] + parts[1:], check=True, capture_output=True, text=True)
    except (subprocess.CalledProcessError, OSError):
        return None

    output = (result.stdout or result.stderr).strip()
    return output.splitlines()[0] if output else None


def install_packages(packages, install):
    for category, pkgs in packages.items():
        log(f"Installing {category}...")
        install(pkgs)


# --- Windows ---
def refresh_windows_env():
    import winreg

    roots = [
        (winreg.HKEY_CURRENT_USER, "Environment"),
        (winreg.HKEY_LOCAL_MACHINE,
         r"SYSTEM\CurrentControlSet\Control\Session Manager\Environment"),
    ]

    def read(root, subkey, name):
        try:
            with winreg.OpenKey(root, subkey) as key:
                value, _ = winreg.QueryValueEx(key, name)
        except OSError:
            return None
        return os.path.expandvars(value) if isinstance(value, str) else None

    for root, subkey in roots:
        for name in WINDOWS_ENV_VARS:
            value = read(root, subkey, name)
            if value:
                os.environ[name] = value

    chunks = [os.environ.get("PATH", "")]
    chunks += [read(root, subkey, "Path") or "" for root, subkey in roots]

    symlink = os.environ.get("NVM_SYMLINK")
    if symlink:
        chunks.append(symlink)

    merged = []
    for chunk in chunks:
        for entry in chunk.split(os.pathsep):
            if entry and entry not in merged:
                merged.append(entry)

    os.environ["PATH"] = os.pathsep.join(merged)


def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except (AttributeError, OSError):
        return False


def install_scoop_packages(pkgs):
    for pkg in pkgs:
        probe = WINDOWS_PROBES.get(pkg)
        if probe and check_command_exists(probe):
            ok(f"{pkg} already installed")
            continue

        if run_command(f"scoop install {pkg}", label=pkg):
            ok(f"{pkg} installed")
            refresh_windows_env()


def install_win32yank_windows():
    """Fallback for when win32yank is missing from the configured scoop buckets."""
    if check_command_exists("win32yank"):
        return True

    shims = os.path.join(os.path.expanduser("~"), "scoop", "shims")
    if not os.path.isdir(shims):
        record_failure("win32yank", f"no scoop shims directory at {shims}")
        return False

    log("Falling back to the win32yank release archive...")
    archive = os.path.join(os.environ.get("TEMP", "."), "win32yank.zip")
    try:
        urllib.request.urlretrieve(WIN32YANK_URL, archive)
        with zipfile.ZipFile(archive) as zf:
            zf.extract("win32yank.exe", shims)
    except (OSError, KeyError, zipfile.BadZipFile) as e:
        record_failure("win32yank", str(e))
        return False

    ok(f"win32yank installed to {shims}")
    return True


def install_node_windows():
    if check_command_exists("nvm"):
        ok("nvm already installed")
    else:
        log("Installing nvm...")
        if not run_command("scoop install nvm", label="nvm"):
            return False
        refresh_windows_env()
        ok("nvm installed")

    node = shutil.which("node")
    symlink = os.environ.get("NVM_SYMLINK", "")
    if node and symlink and not node.lower().startswith(symlink.lower()):
        warn(f"Existing Node install at {node} is not managed by nvm.")
        warn(f"nvm wants to own {symlink} - uninstall that Node first if the steps below fail.")

    if not is_admin():
        warn("Not running as administrator, so 'nvm use' cannot create its symlink.")
        warn("Re-run this script from an elevated terminal if the Node install fails.")

    log(f"Installing Node {NODE_VERSION}...")
    if not run_command(f"nvm install {NODE_VERSION}", label="Node"):
        return False
    if not run_command(f"nvm use {NODE_VERSION}", label="nvm use"):
        return False

    refresh_windows_env()
    ok(f"Node {NODE_VERSION} installed")

    log("Installing pnpm globally...")
    if not run_command("npm install -g pnpm", label="pnpm"):
        return False

    ok("pnpm installed")
    return True


def setup_windows():
    section("Detected Windows")

    if not check_command_exists("scoop"):
        err("Scoop is not installed")
        print("\nInstall it first by running this in PowerShell:")
        print("  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser")
        print("  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression")
        sys.exit(1)

    install_packages(WINDOWS_PACKAGES, install_scoop_packages)
    install_win32yank_windows()
    install_node_windows()


# --- Linux ---
def install_apt_packages(pkgs):
    if run_command(["sudo", "apt", "install", "-y"] + pkgs, label=" ".join(pkgs)):
        ok(f"{len(pkgs)} package(s) installed")


def check_go_version():
    version = capture_output("go version")
    if version is None:
        warn("Go is not on PATH, gopls will not install")
        return

    match = re.search(r"go(\d+)\.(\d+)", version)
    if match is None:
        return

    found = (int(match.group(1)), int(match.group(2)))
    wanted = ".".join(str(n) for n in MIN_GO_VERSION)
    if found < MIN_GO_VERSION:
        warn(f"Go {found[0]}.{found[1]} is too old for current gopls (needs {wanted}+).")
        warn("Install a newer toolchain from https://go.dev/dl/ instead of golang-go.")


def install_node_linux():
    if os.path.isfile(os.path.expanduser("~/.nvm/nvm.sh")):
        ok("nvm already installed")
    else:
        log(f"Installing nvm {NVM_VERSION}...")
        if not run_command(f"curl -o- {NVM_INSTALL_URL} | bash", shell=True, label="nvm"):
            return False
        ok("nvm installed")

    log(f"Installing Node {NODE_VERSION}, pnpm and tree-sitter-cli...")
    script = (f"{NVM_SOURCE} "
              f"nvm install {NODE_VERSION} && "
              f"nvm alias default {NODE_VERSION} && "
              f"nvm use {NODE_VERSION} && "
              f"npm install -g pnpm tree-sitter-cli")
    if not run_bash(script, label="Node/pnpm/tree-sitter-cli"):
        return False

    ok(f"Node {NODE_VERSION}, pnpm and tree-sitter-cli installed")
    return True


def install_win32yank_linux():
    if check_command_exists("win32yank"):
        ok("win32yank already installed")
        return True

    log("Installing win32yank for WSL clipboard support...")
    commands = [
        f"curl -sLo /tmp/win32yank.zip {WIN32YANK_URL}",
        "unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe",
        "chmod +x /tmp/win32yank.exe",
        "sudo mv /tmp/win32yank.exe /usr/local/bin/",
    ]

    for cmd in commands:
        if not run_command(cmd, shell=True, label="win32yank"):
            return False

    ok("win32yank installed")
    return True


def install_nvim_linux():
    log(f"Installing Neovim {NVIM_VERSION}...")
    commands = [
        f"curl -sLo /tmp/nvim.tar.gz {NVIM_URL}",
        "tar -xzf /tmp/nvim.tar.gz -C /tmp",
        "sudo rm -rf /opt/nvim",
        "sudo mv /tmp/nvim-linux-x86_64 /opt/nvim",
        "sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim",
    ]

    for cmd in commands:
        if not run_command(cmd, shell=True, label="Neovim"):
            return False

    ok(f"Neovim {NVIM_VERSION} installed")
    return True


def setup_linux():
    section("Detected Linux/WSL")

    log("Updating package lists...")
    run_command(["sudo", "apt", "update"], label="apt update")

    install_packages(LINUX_PACKAGES, install_apt_packages)
    check_go_version()

    install_node_linux()
    install_win32yank_linux()
    install_nvim_linux()

    log("Setting timezone to America/Argentina/Buenos_Aires...")
    if run_command("sudo timedatectl set-timezone America/Argentina/Buenos_Aires",
                   label="timezone"):
        ok("Timezone set")


# --- Version Reporting ---
def print_versions():
    section("Installed versions")

    python_cmd = "python --version" if platform.system() == "Windows" else "python3 --version"
    version_commands = {
        "nvim": "nvim --version",
        "node": "node --version",
        "npm": "npm --version",
        "pnpm": "pnpm --version",
        "go": "go version",
        "python": python_cmd,
        "git": "git --version",
        "cmake": "cmake --version",
        "rg": "rg --version",
        "tree-sitter": "tree-sitter --version",
    }

    def report(name, value):
        # Pad before painting, escape codes would throw the column off
        print(f"  {name:12} "
              + (value if value else paint(ORANGE, "Not found or not in PATH")))

    for name, cmd in version_commands.items():
        report(name, capture_output(cmd))

    for name in ("gcc", "make", "win32yank"):
        report(name, shutil.which(name))


def print_summary():
    if not FAILURES:
        section("Setup complete")
        return

    section(f"Setup finished with {len(FAILURES)} failure(s)", RED)
    for label in FAILURES:
        err(label)


def main():
    section("Development Environment Setup")

    system = platform.system()
    if system == "Linux":
        setup_linux()
    elif system == "Windows":
        setup_windows()
    else:
        err(f"Unsupported platform: {system}")
        sys.exit(1)

    print_versions()
    print_summary()

    print("\nNext steps:")
    print("  1. Restart your terminal")
    print("  2. Open Neovim, Mason will auto-install LSP servers")
    print("  3. Install Comic Mono and Neovide manually if you want them")
    print("")

    sys.exit(1 if FAILURES else 0)


if __name__ == "__main__":
    main()
